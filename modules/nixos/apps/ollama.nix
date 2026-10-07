{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.apps.ollama;
  nvidiaCapabilities = config.features.hardware.nvidia.cudaCapabilities or [ ];
  # nixpkgs' default ollama-cuda build excludes pre-Turing GPUs (see
  # features.hardware.nvidia.cudaCapabilities); rebuild it for this card's
  # capability instead of silently running on CPU.
  ollamaPackage =
    if nvidiaCapabilities != [ ] then
      pkgs.ollama-cuda.override {
        cudaArches = map (cap: "sm_" + lib.replaceStrings [ "." ] [ "" ] cap) nvidiaCapabilities;
      }
    else
      pkgs.ollama-cuda;
in {
  options.features.apps.ollama = {
    enable = mkEnableOption (lib.mdDoc ''
      Ollama server for running local LLMs, with NVIDIA CUDA acceleration.

      Features:
      - HTTP API bound to localhost only (127.0.0.1:11434), suitable for
        local tools such as the Obsidian Web Clipper's "Interpreter" feature
      - Pulls `loadModels` automatically on service start
      - `contextLength` raised above Ollama's small default so long inputs
        (e.g. a 15-45 minute video transcript, ~8-10k tokens) aren't
        silently truncated
      - `OLLAMA_ORIGINS` set to allow browser-extension origins (e.g. the
        Obsidian Web Clipper's Interpreter), which Ollama otherwise
        rejects with a 403 since they don't send a normal http(s) origin

      Dependencies: features.hardware.nvidia must be enabled for CUDA
      acceleration; falls back to CPU-only inference otherwise.

      Model choice: qwen3:8b (Q4_K_M, ~5.2GB) is the default. It fits
      entirely in an 8GB GPU alongside the KV cache a long transcript
      needs, so it stays fully GPU-accelerated; qwen3:14b's weights alone
      (~9.3GB) already exceed 8GB VRAM and would spill onto the CPU,
      making it noticeably slower for repeated summarization use without
      a meaningful quality gain for this task.
    '');

    loadModels = mkOption {
      type = types.listOf types.str;
      default = [ "qwen3:8b" ];
      example = [ "qwen3:8b" "gemma3" ];
      description = "Models to pull automatically via `ollama pull` on service start.";
    };

    contextLength = mkOption {
      type = types.int;
      default = 16384;
      example = 8192;
      description = ''
        Default context window (in tokens) via `OLLAMA_CONTEXT_LENGTH`.
        Ollama's own default (a few thousand tokens) is too small to hold
        a full video transcript plus prompt and summary.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = ollamaPackage;
      loadModels = cfg.loadModels;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = toString cfg.contextLength;
        # Browser extensions (e.g. Obsidian Web Clipper) send extension-scheme
        # origins that Ollama otherwise rejects with a 403.
        # https://obsidian.md/help/web-clipper/interpreter
        OLLAMA_ORIGINS = "moz-extension://*,chrome-extension://*,safari-web-extension://*";
      };
      # Default host/port (127.0.0.1:11434); not exposed beyond localhost.
    };
  };
}

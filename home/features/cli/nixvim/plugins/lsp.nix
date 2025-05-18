{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.cli.nixvim;
  hostname = config.custom.hostname;
in {
  config = mkIf cfg.enable {
    programs.nixvim.plugins = {
      lsp = {
        enable = true;
        capabilities = ''
          local capabilities = vim.lsp.protocol.make_client_capabilities()

          -- Explicitly enable code action capabilities
          capabilities.textDocument.codeAction = {
            dynamicRegistration = true,
            codeActionLiteralSupport = {
              codeActionKind = {
                valueSet = {
                  "",
                  "quickfix",
                  "refactor",
                  "refactor.extract",
                  "refactor.inline",
                  "refactor.rewrite",
                  "source",
                  "source.organizeImports",
                }
              }
            },
            dataSupport = true,
            resolveSupport = {
              properties = { "edit" }
            }
          }

          capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        '';
        servers = {
          # Nix
          nixd = {
            enable = true;
            settings = {
              schemaOverlays =
                [{ fromPath = "${pkgs.devenv}/modules/devenv.nix"; }];
            };
          };
          # C/C++
          clangd.enable = true;
          #Erlang
          erlangls.enable = true;
          # Python
          #pylsp.enable = true;
          jedi_language_server.enable = true;
          # Lua
          lua_ls.enable = true;
          # Rust
          rust_analyzer.enable = true;
          rust_analyzer.installCargo = true;
          rust_analyzer.installRustc = true;
          # YAML
          yamlls.enable = true;
          # Java
          java_language_server.enable = true;
        };

        keymaps.lspBuf = {
          "gd" = "definition";
          "gD" = "references";
          "gt" = "type_definition";
          "gi" = "implementation";
          "K" = "hover";
          "<leader>a" = "code_action";
          "<leader>rn" = "rename";
          "<leader>f" = "format";
        };

        # Define diagnostic navigation keymaps
        keymaps.diagnostic = {
          "[d" = "goto_prev"; # Go to previous diagnostic
          "]d" = "goto_next"; # Go to next diagnostic
          "gl" = "open_float";
        };

        onAttach = ''
          -- Set custom symbols for diagnostics
          local signs = { Error = "", Warn = "", Hint = "", Info = "" }
          for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
          end

          -- Configure diagnostics display
          vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            update_in_insert = false,
            underline = true,
            severity_sort = true,
            float = {
              focusable = false,
              style = "minimal",
              border = "rounded",
              source = "always",
              header = "",
              prefix = "",
            },
          })

          -- Define the quickfix function and keybinding (not available as a standard function)
          local function quickfix()
            vim.lsp.buf.code_action({
              filter = function(a) return a and a.isPreferred end,
              apply = true
            })
          end

          -- Add quickfix keybinding manually
          vim.keymap.set("n", "gk", quickfix, 
            { buffer = vim.api.nvim_get_current_buf(), desc = "Apply preferred code action", noremap = true, silent = true })
        '';
      };
    };
  };
}

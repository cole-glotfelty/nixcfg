{ lib, stdenv, fetchFromGitLab, makeWrapper, bash, fzf, fd, tmux }:

stdenv.mkDerivation {
  pname = "tmux-sessionizer";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "cole-glotfelty";
    repo = "shell-scripts";
    rev = "35fc8e79946806a3dfc12a766fd970fb277a9283";
    sha256 = "1cz5kvr644mqhz52mfgmph5jbs3fn8nbpanaz631nibbl0j01bck";
  };

  buildInputs = [ ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    ls -l
    mkdir -p $out/bin
    cp tmux-sessionizer.sh $out/bin/tmux-sessionizer
    chmod u+x $out/bin/tmux-sessionizer
    wrapProgram $out/bin/tmux-sessionizer \
      --prefix PATH : ${lib.makeBinPath [ bash fd fzf tmux ]}
  '';
  meta = with lib; {
    description = "tmux-sessionizer adapted from thePrimeagen";
    homepage = "";
    license = licenses.mit;
    maintainers = with maintainers; [ cole-glotfelty ];
    platforms = platforms.unix;

  };
}

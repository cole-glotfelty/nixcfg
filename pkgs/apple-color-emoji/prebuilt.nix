{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "apple-color-emoji";
  version = "17.4";

  # Use the prebuilt release from samuelngs/apple-emoji-linux
  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-linux/releases/download/v${version}/AppleColorEmoji.ttf";
    sha256 = "1wahjmbfm1xgm58madvl21451a04gxham5vz67gqz1cvpi0cjva8";
  };

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    
    install -Dm444 $src $out/share/fonts/truetype/AppleColorEmoji.ttf
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Apple Color Emoji font (prebuilt from GitHub release)";
    homepage = "https://github.com/samuelngs/apple-emoji-linux";
    license = licenses.ofl; # SIL Open Font License
    platforms = platforms.all;
    maintainers = [ ];
  };
}
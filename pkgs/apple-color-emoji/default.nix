{ lib, stdenvNoCC, apple-emoji }:

stdenvNoCC.mkDerivation rec {
  pname = "apple-color-emoji";
  version = "17.4";

  src = apple-emoji;

  installPhase = ''
    runHook preInstall
    
    install -m444 -Dt $out/share/fonts/truetype/apple-color-emoji fonts/AppleColorEmoji.ttf
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Apple Color Emoji font for Linux/NixOS";
    homepage = "https://github.com/zhdsmy/apple-emoji";
    license = licenses.ofl; # SIL Open Font License
    platforms = platforms.all;
    maintainers = [ ];
  };
}
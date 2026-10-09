{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
stdenvNoCC.mkDerivation rec {
  pname = "agent-canvas";
  version = "1.26.0";

  src = fetchurl {
    url = "https://github.com/OpenHands/OpenHands/releases/download/v${version}/OpenHands-Agent-Canvas-${version}-universal.dmg";
    hash = "sha256-xAVNNjq47FALEaKjCloyINMyvoM1sPpnKtglyWLiLoc=";
  };

  nativeBuildInputs = [_7zz];

  sourceRoot = ".";

  unpackPhase = ''
    7zz x -snld $src
  '';

  installPhase = ''
    mkdir -p $out/Applications
    find . -maxdepth 2 -name '*.app' -exec cp -R {} $out/Applications/ \;
  '';

  dontFixup = true;

  meta = {
    description = "OpenHands Agent Canvas desktop app";
    homepage = "https://github.com/OpenHands/OpenHands";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}

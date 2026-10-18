{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}: let
  sources = {
    aarch64-darwin = {
      asset = "macos-arm64";
      hash = "sha256-w1ow1CYAzJV0tEo57XH884L4UTv1jOts0RuZgLSfEww=";
    };
    aarch64-linux = {
      asset = "linux-arm64";
      hash = "sha256-9l/iS1tav7g6affVSC98ov794gKIme8qEKd3Ma1uz4Q=";
    };
    x86_64-linux = {
      asset = "linux-x86_64";
      hash = "sha256-BOlxZWLN+JziQBgeKH6Lee4KLAlrAhUdT2kkfYbT8YY=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
  stdenvNoCC.mkDerivation rec {
    pname = "leaf";
    version = "1.29.1";

    src = fetchurl {
      url = "https://github.com/RivoLink/leaf/releases/download/${version}/leaf-${source.asset}";
      inherit (source) hash;
    };

    dontUnpack = true;

    nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [autoPatchelfHook];
    buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [stdenv.cc.cc.lib];

    installPhase = ''
      install -Dm755 $src $out/bin/leaf
    '';

    meta = {
      description = "Terminal Markdown previewer";
      homepage = "https://github.com/RivoLink/leaf";
      license = lib.licenses.mit;
      platforms = builtins.attrNames sources;
      mainProgram = "leaf";
    };
  }

{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: let
  version = "7.4.0";
  releases = {
    aarch64-darwin = {
      platform = "aarch64-macos";
      hash = "sha256-RJi41C8gBPmAL4W/OlMzSFXWLxt87Wc4ckAhwcbsnnc=";
    };
    x86_64-linux = {
      platform = "x86_64-linux";
      hash = "sha256-F4JTMGsb0SjlMEwCNfq7cHeKNCAOba5u2ZTpttyAyAg=";
    };
  };
  release = releases.${stdenv.hostPlatform.system};
in
  stdenv.mkDerivation {
    pname = "tokensave";
    inherit version;

    src = fetchurl {
      url = "https://github.com/aovestdipaperino/tokensave/releases/download/v${version}/tokensave-v${version}-${release.platform}.tar.gz";
      inherit (release) hash;
    };

    sourceRoot = ".";
    dontBuild = true;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [stdenv.cc.cc.lib];

    installPhase = ''
      runHook preInstall
      install -Dm755 tokensave $out/bin/tokensave
      runHook postInstall
    '';

    meta = {
      description = "Semantic code intelligence MCP server for AI coding agents";
      homepage = "https://github.com/aovestdipaperino/tokensave";
      license = lib.licenses.mit;
      mainProgram = "tokensave";
      platforms = builtins.attrNames releases;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }

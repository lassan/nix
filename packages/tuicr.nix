{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}: let
  version = "0.23.1";
  releases = {
    aarch64-darwin = {
      platform = "aarch64-apple-darwin";
      hash = "sha256-i63AMsj9knSWwy1aKMuHZdWSwdikdHafhzvImVmuZ2U=";
    };
    x86_64-linux = {
      platform = "x86_64-unknown-linux-gnu";
      hash = "sha256-nMH+IJgD+siZPs2n0cC9NVsfzDTipnRuoy/KAGoukA8=";
    };
  };
  release = releases.${stdenv.hostPlatform.system};
in
  stdenv.mkDerivation {
    pname = "tuicr";
    inherit version;

    src = fetchurl {
      url = "https://github.com/agavra/tuicr/releases/download/v${version}/tuicr-${version}-${release.platform}.tar.gz";
      inherit (release) hash;
    };

    sourceRoot = ".";
    dontBuild = true;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [stdenv.cc.cc.lib zlib];

    installPhase = ''
      runHook preInstall
      install -Dm755 tuicr $out/bin/tuicr
      runHook postInstall
    '';

    meta = {
      description = "Terminal UI for reviewing code diffs";
      homepage = "https://github.com/agavra/tuicr";
      license = lib.licenses.mit;
      mainProgram = "tuicr";
      platforms = builtins.attrNames releases;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }

{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "leaf";
  version = "1.29.1";

  src = fetchFromGitHub {
    owner = "RivoLink";
    repo = "leaf";
    tag = version;
    hash = "sha256-+J8c6aoM2GqZMJe2XUiY4A6T1qqw1s1+kVMhdHKSt8o=";
  };

  cargoHash = "sha256-pbzCRd6BoImGL2DXInGRiiobk1CnMEmmeH1tetzNLnQ=";

  meta = {
    description = "Terminal Markdown previewer";
    homepage = "https://github.com/RivoLink/leaf";
    license = lib.licenses.mit;
    mainProgram = "leaf";
  };
}

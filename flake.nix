{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      version = "1.0.4";
      assets = {
        aarch64-darwin = {
          suffix = "darwin-arm64";
          hash = "sha256-HOcSMfuUADCKzr/+rsCPH2onMHql1uZQlZ8iCj5N6Dg=";
        };
        aarch64-linux = {
          suffix = "linux-arm64";
          hash = "sha256-8dJ3n7XcF9pzr3+oaPSW3g/sZZDhRNEjQa1c6QafMPs=";
        };
        x86_64-darwin = {
          suffix = "darwin-x86_64";
          hash = "sha256-wvUoJQYbDdlTQoBR24GuzUeGs+5EOseK7iy0D16vvbA=";
        };
        x86_64-linux = {
          suffix = "linux-x86_64";
          hash = "sha256-6lvZsM6kNoGwxGStVPJAcRffUfmDtSS3j7VMjFb/JaU=";
        };
      };
      forAllSystems = nixpkgs.lib.genAttrs (builtins.attrNames assets);
      mkHooky =
        pkgs:
        let
          asset = assets.${pkgs.stdenv.hostPlatform.system};
        in
        pkgs.stdenv.mkDerivation {
          pname = "hooky";
          inherit version;
          src = pkgs.fetchurl {
            url = "https://github.com/brandonchinn178/hooky/releases/download/v${version}/hooky-${version}-${asset.suffix}";
            inherit (asset) hash;
          };
          dontUnpack = true;
          nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.autoPatchelfHook
          ];
          buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.gmp
          ];
          installPhase = ''
            install -Dm755 $src $out/bin/hooky
          '';
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = mkHooky pkgs;
        }
      );

      overlays.default = _final: prev: {
        hooky = mkHooky prev;
      };
    };
}

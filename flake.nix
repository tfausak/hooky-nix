{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      version = "1.0.7";
      assets = {
        aarch64-darwin = {
          suffix = "darwin-arm64";
          hash = "sha256-SoJ3d8Jw+lYImt4jsNAB5SIrq50xw4gBUUVlex6llWc=";
        };
        aarch64-linux = {
          suffix = "linux-arm64";
          hash = "sha256-7GHatpey1wGyTsNynRnhlu46Xg4IVtbXaoaSVk+Vf/8=";
        };
        x86_64-darwin = {
          suffix = "darwin-x86_64";
          hash = "sha256-I+3dkUgiApJx5P0Lx2N3XUop4vTuW3D93+djFA+jKe0=";
        };
        x86_64-linux = {
          suffix = "linux-x86_64";
          hash = "sha256-sn34VJNrNYuUzbZkQC7dY8tOaL2rr2/SUwlqWX0z+jg=";
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

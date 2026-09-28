{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      version = "1.0.6";
      assets = {
        aarch64-darwin = {
          suffix = "darwin-arm64";
          hash = "sha256-z7M99eWJDQcl0UN32yQPLu7c8PgMflZwLyWfpGr2OCs=";
        };
        aarch64-linux = {
          suffix = "linux-arm64";
          hash = "sha256-X79gPoselGaTi71e5zwvYT/6hyckC+V4Z4La9EEAo/A=";
        };
        x86_64-darwin = {
          suffix = "darwin-x86_64";
          hash = "sha256-v48PDrFmDVlUcmZs0FijbYYYr3d7r7goJHQKBInkU6o=";
        };
        x86_64-linux = {
          suffix = "linux-x86_64";
          hash = "sha256-8lS7AfhzLVrkWtiyOS+x42x5IffAP5xc/QVC0E5vAys=";
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

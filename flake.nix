{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      version = "1.0.5";
      assets = {
        aarch64-darwin = {
          suffix = "darwin-arm64";
          hash = "sha256-5lyuyhOTPs0GeWxBKYSh9ycB+NZJguGHYhyG+S7h8/8=";
        };
        aarch64-linux = {
          suffix = "linux-arm64";
          hash = "sha256-BMlWqZKpD/fY5Pm5apCQIRfa9plKm1oKIrdeXdi1F8M=";
        };
        x86_64-darwin = {
          suffix = "darwin-x86_64";
          hash = "sha256-EH9bvYJZIzWNMvHfE7iUzhyHSANGw05+3dvmf7/R178=";
        };
        x86_64-linux = {
          suffix = "linux-x86_64";
          hash = "sha256-Qwv+oIp8tbBCsqjnHpjCi9uAX19y9yTVRfg4QdJYufM=";
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

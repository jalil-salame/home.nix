{
  description = "My home-manager configuration";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz"; # nixpkgs unstable
  inputs.flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";

  outputs = { self, nixpkgs, flake-schemas }:
    let
      # Helpers for producing system-specific outputs
      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
      forEachSupportedSystem = f: lib.genAttrs supportedSystems (system: f (import nixpkgs { inherit system; }));

    in
    {
      # Schemas tell Nix about the structure of your flake's outputs
      schemas = flake-schemas.schemas;

      formatter = forEachSupportedSystem (pkgs: pkgs.nixpkgs-fmt);

      nixosModules = rec {
        default = homeManager;
        homeManager = homeManager-24-05;
        homeManager-24-05 = import ./home { state = 2405; };
        homeManager-23-11 = import ./home { state = 2311; };
      };
    };
}

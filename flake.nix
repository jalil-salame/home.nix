{
  description = "My home-manager configuration";

  inputs.stylix.url = "https://flakehub.com/f/danth/stylix/0.1.*.tar.gz";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.home-manager.follows = "home-manager";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz"; # nixpkgs unstable
  inputs.home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.1.*.tar.gz"; # home-manager unstable
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";

  outputs = { nixpkgs, flake-schemas, stylix, ... }:
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
        homeManager = import ./home { inherit stylix; };
      };
    };
}

{
  description = "My home-manager configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # inputs.nvim-config.url = "github:jalil-salame/nvim-config";
  # inputs.nvim-config.inputs.nixpkgs.follows = "nixpkgs";
  # inputs.nvim-config.inputs.flake-utils.follows = "flake-utils";
  # inputs.nvim-config.inputs.home-manager.follows = "home-manager";
  # inputs.home-manager.url = "github:nix-community/home-manager";
  # inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        nixosModules = rec {
          default = homeManager;
          homeManager = homeManager-24-05;
          homeManager-24-05 = import ./home { state = 2405; };
          homeManager-23-11 = import ./home { state = 2311; };
          users = users-24-05;
          users-24-05 = import ./home { state = 2405; };
          users-23-11 = import ./home { state = 2311; };
        };
      });
}

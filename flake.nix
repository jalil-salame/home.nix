{
  description = "My home-manager configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nvim-config.url = "github:jalil-salame/nvim-config";
  inputs.nvim-config.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nvim-config.inputs.flake-utils.follows = "flake-utils";
  inputs.nvim-config.inputs.home-manager.follows = "home-manager";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, nvim-config, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        nvimModules = unstable:
          if unstable
          then with nvim-config.nixosModules; [ nvim-config nixneovim ]
          else with nvim-config.nixosModules; [ nvim-config nixneovim-23-11 ];
        overlays = [ nvim-config.overlays.nixneovim nvim-config.overlays.neovim-nightly ];
        pkgs = import nixpkgs { inherit system overlays; };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        lib.home-manager = import ./home { inherit nvimModules; };
      });
}

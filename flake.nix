{
  description = "My home-manager configuration";

  inputs.stylix.url = "https://flakehub.com/f/danth/stylix/0.1.*.tar.gz";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.home-manager.follows = "home-manager";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  inputs.nvim-config.url = "github:jalil-salame/nvim-config";
  inputs.nvim-config.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nvim-config.inputs.home-manager.follows = "home-manager";

  inputs.home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.1.*.tar.gz";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";

  inputs.jpassmenu.url = "github:jalil-salame/jpassmenu";
  inputs.jpassmenu.inputs.nixpkgs.follows = "nixpkgs";

  inputs.audiomenu.url = "github:jalil-salame/audiomenu";
  inputs.audiomenu.inputs.nixpkgs.follows = "nixpkgs";
  inputs.audiomenu.inputs.flake-schemas.follows = "flake-schemas";

  outputs = { nixpkgs, flake-schemas, stylix, nvim-config, jpassmenu, audiomenu, ... }:
    let
      # Helpers for producing system-specific outputs
      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
      forEachSupportedSystem = f: lib.genAttrs supportedSystems (system: f (import nixpkgs { inherit system; }));
      # Module documentation
      doc = forEachSupportedSystem (pkgs: { doc = import ./docs { inherit pkgs lib; }; });
    in
    {
      # Schemas tell Nix about the structure of your flake's outputs
      schemas = flake-schemas.schemas;

      formatter = forEachSupportedSystem (pkgs: pkgs.nixpkgs-fmt);

      packages = doc;

      overlays = lib.genAttrs supportedSystems (system: final: prev: {
        inherit (jpassmenu.packages.${system}) jpassmenu;
        inherit (audiomenu.packages.${system}) audiomenu;
      } // nvim-config final prev);

      nixosModules = rec {
        default = homeManagerModule;
        nixosModule = import ./home { }; # provide stylix thourgh the nixos module
        homeManagerModule = import ./home { inherit stylix; };
      };
    };
}

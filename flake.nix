{
  description = "My home-manager configuration";

  inputs.stylix.url = "https://flakehub.com/f/danth/stylix/0.1.*.tar.gz";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.home-manager.follows = "home-manager";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  inputs.nvim-config.url = "github:jalil-salame/nvim-config";
  inputs.nvim-config.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nvim-config.inputs.home-manager.follows = "home-manager";
  inputs.nvim-config.inputs.flake-schemas.follows = "flake-schemas";

  inputs.home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.1.*.tar.gz";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";

  inputs.jpassmenu.url = "github:jalil-salame/jpassmenu";
  inputs.jpassmenu.inputs.nixpkgs.follows = "nixpkgs";
  inputs.jpassmenu.inputs.flake-schemas.follows = "flake-schemas";

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
      docs = forEachSupportedSystem (pkgs: import ./docs { inherit pkgs lib; });
    in
    {
      # Schemas tell Nix about the structure of your flake's outputs
      inherit (flake-schemas) schemas;

      formatter = forEachSupportedSystem (pkgs: pkgs.nixpkgs-fmt);

      packages = docs;

      nixosModules =
        let
          overlays = [
            jpassmenu.overlays.default
            audiomenu.overlays.default
            nvim-config.overlays.nixneovim
            nvim-config.overlays.neovim-nightly
          ];
          homeManagerModule = import ./home { inherit overlays nvim-config stylix; };
        in
        {
          default = homeManagerModule;
          nixosModule = import ./home { inherit nvim-config overlays; }; # provide stylix thourgh the nixos module
        };
    };
}

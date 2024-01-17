{
  description = "My home-manager configuration";

  inputs.stylix.url = "https://flakehub.com/f/danth/stylix/0.1.*.tar.gz";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.home-manager.follows = "home-manager";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  inputs.jpassmenu.url = "github:jalil-salame/jpassmenu";
  inputs.jpassmenu.inputs.nixpkgs.follows = "nixpkgs";
  inputs.jpassmenu.inputs.flake-schemas.follows = "flake-schemas";

  inputs.audiomenu.url = "github:jalil-salame/audiomenu";
  inputs.audiomenu.inputs.nixpkgs.follows = "nixpkgs";
  inputs.audiomenu.inputs.flake-schemas.follows = "flake-schemas";

  inputs.nvim-config.url = "github:jalil-salame/nvim-config";
  inputs.nvim-config.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nvim-config.inputs.home-manager.follows = "home-manager";
  inputs.nvim-config.inputs.flake-schemas.follows = "flake-schemas";

  inputs.home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.1.*.tar.gz";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";

  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { self
    , nixpkgs
    , flake-schemas
    , stylix
    , nvim-config
    , jpassmenu
    , audiomenu
    , home-manager
    , pre-commit-hooks
    }:
    let
      # Helpers for producing system-specific outputs
      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
      forEachSupportedSystem = f: lib.genAttrs supportedSystems (system: f { pkgs = (import nixpkgs { inherit system; }); inherit system; });
    in
    {
      # Schemas tell Nix about the structure of your flake's outputs
      inherit (flake-schemas) schemas;

      checks = forEachSupportedSystem ({ pkgs, system }:
        let src = builtins.path { path = ./.; name = "home.nix"; }; in
        {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            inherit src;
            hooks.nixpkgs-fmt.enable = true;
          };
        });

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixpkgs-fmt);

      overlays = {
        nixneovim = nvim-config.overlays.nixneovim;
        neovim-nightly = nvim-config.overlays.neovim-nightly;
        jpassmenu = jpassmenu.overlays.default;
        audiomenu = audiomenu.overlays.default;
      };

      nixosModules =
        let
          overlays = builtins.attrValues self.overlays;
          homeManagerModule = import ./home { inherit overlays nvim-config stylix; };
        in
        {
          default = homeManagerModule;
          nixosModule = import ./home { inherit nvim-config overlays; }; # provide stylix thourgh the nixos module
        };

      # Module documentation
      packages = forEachSupportedSystem ({ pkgs, system }: {
        inherit (pkgs.callPackage ./docs { }) docs markdown;
        # TODO: breaks `nix flake show`
        home-config = (home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; overlays = builtins.attrValues self.overlays; };
          modules = [
            self.nixosModules.default
            ({ config, ... }: {
              home.username = "example";
              home.homeDirectory = "/home/${config.home.username}";

              programs.home-manager.enable = true;

              jhome.enable = true;
            })
          ];
        }).activationPackage;
      });

      devShells = forEachSupportedSystem ({ pkgs, system }: { default = pkgs.mkShell { inherit (self.checks.${system}.pre-commit-check) shellHook; }; });
    };
}

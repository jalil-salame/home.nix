{ nvimModules }: { users, unstable }: {
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users = users;
  home-manager.sharedModules =
    # Add NeoVIM modules
    (nvimModules unstable) ++ [ ./shared.nix ];
}

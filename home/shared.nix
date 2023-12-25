{ pkgs, config, ... }: {
  home.stateVersion = "23.11";
  home.packages = [
    pkgs.gopass
    pkgs.gitoxide
  ];
  # Shell aliases
  ## Verbose Commands
  home.shellAliases.cp = "cp --verbose";
  home.shellAliases.ln = "ln --verbose";
  home.shellAliases.mv = "mv --verbose";
  home.shellAliases.mkdir = "mkdir --verbose";
  home.shellAliases.rename = "rename --verbose";
  ## Add Color
  home.shellAliases.grep = "grep --color=auto";
  home.shellAliases.ip = "ip --color=auto";
  ## Use exa/eza
  home.shellAliases.tree = "eza --tree";
  # Session variables
  home.sessionVariables.CARGO_HOME = "${config.xdg.dataHome}/cargo";
  home.sessionVariables.RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
  home.sessionVariables.GOPATH = "${config.xdg.dataHome}/go";
  # Program configurations
  ## direnv (source env on cd)
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  ## eza (an ls replacement)
  programs.eza.enable = true;
  programs.eza.enableAliases = true;
  programs.eza.git = true;
  programs.eza.icons = true;
  ## git
  programs.git.enable = true;
  programs.git.delta.enable = true;
  programs.git.lfs.enable = true;
  programs.git.extraConfig.init.defaultBranch = "trunk";
  ## gpg
  programs.gpg.enable = true;
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";
  ## lazygit
  programs.lazygit.enable = true;
  ## nushell
  programs.nushell.enable = true;
  ## pass
  programs.password-store.enable = true;
  programs.password-store.settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
  ## ssh
  programs.ssh.enable = true;
  ## zoxide (cd replacement)
  programs.zoxide.enable = true;
  ## zsh
  programs.zsh.enable = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.autocd = true;
  programs.zsh.dotDir = ".config/zsh";
  programs.zsh.history.path = "${config.xdg.dataHome}/zsh/zsh_history";
  programs.zsh.syntaxHighlighting.enable = true;
  # XDG directories
  xdg.enable = true;
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;
}


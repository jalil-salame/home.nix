{ config, lib, pkgs, osConfig ? null, ... }:
let
  inherit (config) jhome;
  flatpakEnabled = if osConfig then osConfig.services.flatpak.enable else false;
  cfg = jhome.gui;
  swaycfg = config.wayland.windowManager.sway.config;
  cursor.package = pkgs.nordzy-cursor-theme;
  cursor.name = "Nordzy-cursors";
  iconTheme.name = "Papirus-Dark";
  iconTheme.package = pkgs.papirus-icon-theme;
  orDefault = val: default: if val != null then val else default;
in
{
  options.jhome.gui = lib.mkOption {
    description = lib.mdDoc "Jalil's default GUI configuration.";
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption (lib.mdDoc "GUI applications");
        tempInfo = lib.mkOption {
          description = lib.mdDoc "Temperature info to display in the statusbar.";
          type = lib.types.nullOr lib.types.submodule {
            options.hwmon-path = lib.mkOption {
              description = "Path to the hardware sensor whose temperature to monitor.";
              type = lib.types.str;
              example = "/sys/class/hwmon/hwmon2/temp1_input";
            };
          };
        };
        sway = lib.mkOption {
          description = "Sway window manager configuration.";
          type = lib.types.submodule {
            options = {
              background = lib.mkOption {
                description = lib.mdDoc "The wallpaper to use.";
                type = lib.types.path;
                default = orDefault config.stylix.image (builtins.fetchurl {
                  url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
                  sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
                });
              };
              autostart = lib.mkOption {
                description = lib.mdDoc ''
                  Autostart Sway when logging in to /dev/tty1.

                  This will make it so `exec sway` is run when logging in to TTY1, if
                  you want a non-graphical session (ie. your GPU drivers are broken)
                  you can switch TTYs when logging in by using CTRL+ALT+F2 (for TTY2,
                  F3 for TTY3, etc).
                '';
                type = lib.types.bool;
                default = true;
                example = false;
              };
              exec = lib.mkOption {
                description = "Run commands when starting sway.";
                type = lib.types.submodule {
                  options = {
                    once = lib.mkOption {
                      description = lib.mdDoc "Programs to start only once (`exec`).";
                      type = lib.types.listOf lib.types.str;
                      default = [ ];
                      example = [ "signal-desktop --start-in-tray" ];
                    };
                    always = lib.mkOption {
                      description = lib.mdDoc "Programs to start whenever the config is sourced (`exec_always`).";
                      type = lib.types.listOf lib.types.str;
                      default = [ ];
                      example = [ "signal-desktop --start-in-tray" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };


  config = lib.optionalAttrs (jhome.enable && cfg.enable) {
    home.packages = [
      pkgs.webcord
      pkgs.ferduim
      pkgs.xournalpp
      pkgs.signal-desktop
      pkgs.lxqt.pcmanfm-qt
    ] ++ lib.optional flatpakEnabled pkgs.flatpak;

    fonts.fontconfig.enable = true;

    # Browser
    programs.firefox.enable = true;
    # Dynamic Menu
    programs.fuzzel.enable = true;
    programs.fuzzel.settings.main.icon-theme = "Papirus-Dark";
    programs.fuzzel.settings.main.terminal = swaycfg.terminal;
    programs.fuzzel.settings.main.layer = "overlay";
    # Video player
    programs.mpv.enable = true;
    programs.mpv.scripts = builtins.attrValues { inherit (pkgs.mpvScripts) uosc thumbfast; };
    # Status bar
    programs.waybar.enable = true;
    programs.waybar.systemd.enable = true;
    programs.waybar.settings = import ./waybar-settings.nix;
    # Terminal
    programs.wezterm.enable = true;
    programs.wezterm.extraConfig = ''
      config = {}
      config.hide_tab_bar_if_only_one_tab = true
      config.window_padding = { left = 1, right = 1, top = 1, bottom = 1 }
      return config
    '';
    # PDF reader
    programs.zathura.enable = true;
    # Auto start sway
    programs.zsh.loginExtra = lib.optionalString cfg.sway.autostart ''
      # Start Sway on login to TTY 1
      if [ "$TTY" = /dev/tty1 ]; then
        exec sway
      fi
    '';

    # Auto configure displays
    services.kanshi.enable = true;
    # Notifications
    services.mako.enable = true;
    services.mako.layer = "overlay";
    services.mako.borderRadius = 8;
    services.mako.defaultTimeout = 15000;

    # Window Manager
    wayland.windowManager.sway.enable = true;
    wayland.windowManager.sway.config = import ./sway-config.nix;

    # Set cursor style
    stylix.cursor = cursor;
    home.pointerCursor.name = cursor.name;
    home.pointerCursor.package = cursor.package;
    home.pointerCursor.gtk.enable = true;

    # Set Gtk theme
    gtk.enable = true;
    gtk.iconTheme = iconTheme;
    gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk.gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    # Set Qt theme
    qt.enable = true;
    qt.platformTheme = "gtk";

    xdg.systemDirs.data = [
      "/usr/share"
      "/var/lib/flatpak/exports/share"
      "${config.xdg.dataHome}/flatpak/exports/share"
    ];
  };
}

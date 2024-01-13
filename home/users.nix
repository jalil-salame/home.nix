{ config, lib, ... }:
let
  inherit (lib) types;
  cfg = config.jhome.user;
in
{
  options.jhome.user = lib.mkOption {
    description = lib.mdDoc "User settings.";
    default = null;
    type = types.nullOr types.submodule {
      options = {
        unlockGpgKeyOnLogin = lib.mkEnableOption "unlocking the gpg key on login";
        defaultIdentity = lib.mkOption {
          description = "The default identity to use in things like git.";
          type = types.submodule {
            options = {
              email = lib.mkOption {
                description = "Primary email adderss";
                type = types.str;
                example = "email@example.org";
              };
              name = lib.mkOption {
                description = "The default name you use.";
                type = types.str;
                example = "John Doe";
              };
              gpgKey = lib.mkOption {
                description = "The keygrip of your GPG key.";
                type = types.nullOr types.str;
                default = null;
                example = "6F4ABB77A88E922406BCE6627AFEEE2363914B76";
              };
            };
          };
        };
      };
    };
  };

  config =
    let
      hasConfig = cfg != null;
      inherit (cfg.defaultIdentity) gpgKey;
      hasKey = gpgKey != null;
      gpgHome = config.programs.gpg.homedir;
      unlockKey = hasConfig && cfg.unlockGpgKeyOnLogin && hasKey;
    in
    lib.optionalAttrs hasConfig
      {
        programs.git.userName = cfg.defaultIdentity.name;
        programs.git.userEmail = cfg.defaultIdentity.email;
        programs.git.signing = lib.optionalAttrs hasKey {
          signByDefault = true;
          key = gpgKey;
        };
      } // lib.optionalAttrs unlockKey {
      xdg.configFile.pam-gnupg.text = ''
        ${gpgHome}

        ${gpgKey}
      '';
    };
}

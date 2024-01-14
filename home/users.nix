{ config, lib, ... }:
let
  inherit (config) jhome;
  inherit (cfg.defaultIdentity) gpgKey;

  cfg = jhome.user;
  hasConfig = jhome.enable && cfg != null;
  hasKey = gpgKey != null;
  gpgHome = config.programs.gpg.homedir;
  unlockKey = hasConfig && cfg.unlockGpgKeyOnLogin && hasKey;
in
{
  config = lib.optionalAttrs hasConfig
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

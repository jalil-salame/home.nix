{ pkgs, lib, ... }:
let
  eval = lib.evalModules { modules = [ ../home/options.nix ]; };
  markdown = (pkgs.nixosOptionsDoc {
    inherit (eval) options;
    transformOptions = option: option // { visible = option.visible && builtins.elemAt option.loc 0 == "jhome"; };
  }).optionsCommonMark;
in
{
  inherit markdown;
  docs = pkgs.stdenvNoCC.mkDerivation {
    name = "home-manager-configuration-book";
    src = ./.;

    patchPhase = ''
      # copy generated options removing the declared by statement
      sed '/^\*Declared by:\*$/,/^$/d' <${markdown} >> src/options.md
    '';

    buildPhase = "${pkgs.mdbook}/bin/mdbook build --dest-dir $out";
  };
}

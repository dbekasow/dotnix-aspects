{ inputs, lib, ... }:
let
  dotnixInputs = inputs;

  wrapMods = files: map
    (file:
      let mod = import file;
      in if builtins.isFunction mod
      then args: mod (args // { inputs = dotnixInputs // args.inputs; })
      else mod)
    files;

  modules = "${inputs.self}/modules";
in
{
  flake.flakeModule.imports = wrapMods (
    lib.pipe inputs.import-tree [
      (i: i.addPath "${modules}/aspects")
      (i: i.addPath "${modules}/parts")
      (i: i.withLib lib)
      (i: i.files)
    ]
  );
}

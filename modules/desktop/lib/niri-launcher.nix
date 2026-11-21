{ key, command, enabled }:
{ config, lib, options, ... }@args:
{
  config = lib.optionalAttrs (options.programs ? niri) (
    lib.mkIf ((config._module.args.dotnixHomeNiriSelected or false) && enabled args) {
      programs.niri.settings.binds.${key}.action = lib.mkDefault (config.lib.niri.actions.spawn command);
    }
  );
}

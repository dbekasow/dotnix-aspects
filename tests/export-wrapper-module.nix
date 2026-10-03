{ lib, inputs, extra, ... }:
{
  options.test = {
    extra = lib.mkOption { type = lib.types.str; };
    self = lib.mkOption { type = lib.types.str; };
    shared = lib.mkOption { type = lib.types.str; };
    fallback = lib.mkOption { type = lib.types.str; };
  };
  config.test = {
    inherit extra;
    inherit (inputs) self;
    inherit (inputs) shared;
    fallback = inputs.libraryOnly;
  };
}

# Dotnix-Aspects

A reusable library of [dendritic](https://github.com/mightyiam/dendritic) NixOS and Home Manager aspects, built on [flake-parts](https://flake.parts/).

Each aspect is a self-contained flake-parts module that configures a single cross-cutting concern across NixOS (`flake.modules.nixos.*`) and Home Manager (`flake.modules.homeManager.*`) classes. Aspects can be composed per host and per user without `specialArgs` or rigid file hierarchies.

## Aspects

All aspects live under `modules/aspects/`. Each file is a flake-parts module contributing to NixOS, Home Manager, or both. Adding or removing a file changes only the capabilities it provides.

| Category       | Classes   | Description                                                    |
| -------------- | --------- | -------------------------------------------------------------- |
| `core/`        | NixOS, HM | Nix, users, secrets, theming, SSH, security, locale, fonts     |
| `system/`      | NixOS     | Boot, disk layout, networking, audio, bluetooth, power         |
| `desktop/`     | NixOS, HM | Compositor, shell, greeter, portals, apps, terminals           |
| `development/` | NixOS, HM | Editor, LSPs, Git, containers, Kubernetes, AI, automation      |
| `term/`        | HM        | Shells, prompt, multiplexer, file tools, monitoring, Nix tools |

## Usage

Add this flake as an input and import its `flakeModule`. See `modules/options.nix` for the host/user schema and `factories.nix` for how configurations are assembled.

```nix
# flake.nix
{
  inputs = {
    dotnix.url = "github:dbekasow/dotnix-aspects";
    dotnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.dotnix.flakeModule # import the aspects library
    ];
    # ...
  };
}
```

## Key Design Decisions

**Dendritic pattern** — Each file owns its feature across all configuration classes. Values are shared via `let`-bindings or flake-parts options, not `specialArgs`.

**Secrets with agenix-rekey** — Host and user secrets are managed through `age.rekey` with local storage mode and a master identity. Password generation is handled declaratively.

**Factory pattern** — `factories.nix` iterates over `dotnix.hosts` and produces `nixosConfigurations`, injecting `core` modules and host metadata automatically.

## License

MIT

{
  description = "Performant, batteries-included completion plugin for Neovim";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    blink-lib.url = "github:saghen/blink.lib";
    blink-lib.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    blink-lib,
    self,
    ...
  }: let
    inherit (nixpkgs) lib;
    inherit (lib.attrsets) genAttrs mapAttrs' nameValuePair;
    inherit (lib.fileset) fileFilter toSource unions;
    inherit (lib.lists) optional;

    systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = genAttrs systems;
    nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});

    version = "1.10.2";
    blink-cmp-package = {
      rustPlatform,
      vimUtils,
      blink-lib,
      stdenv,
      rust-jemalloc-sys,
      git,
    }:
      vimUtils.buildVimPlugin {
        pname = "blink.cmp";
        inherit version;
        src = toSource {
          root = ./.;
          fileset = unions [
            (fileFilter (file: file.hasExt "lua") ./lua)
            ./doc/blink-cmp.txt
          ];
        };

        dependencies = [blink-lib];

        preInstall = ''
          mkdir -p lib
          ln -s $fuzzy_lib/lib/libblink_cmp_fuzzy.* lib/
        '';

        env.fuzzy_lib = rustPlatform.buildRustPackage {
          pname = "blink-fuzzy-lib";
          inherit version;
          src = toSource {
            root = ./.;
            fileset = unions [
              (fileFilter (file: file.hasExt "rs") ./.)
              ./Cargo.toml
              ./Cargo.lock
              ./.cargo
            ];
          };
          cargoLock.lockFile = ./Cargo.lock;
          buildInputs = optional stdenv.hostPlatform.isAarch64 rust-jemalloc-sys;
          nativeBuildInputs = [git];
        };
      };
  in {
    packages = forAllSystems (system: rec {
      blink-cmp = nixpkgsFor.${system}.callPackage blink-cmp-package {inherit (blink-lib.packages.${system}) blink-lib;};
      default = blink-cmp;
    });

    overlays.default = final: prev: {
      vimPlugins = prev.vimPlugins.extend (self': _: {
        blink-cmp = final.callPackage blink-cmp-package {
          blink-lib = self'.blink-lib or (throw "vimPlugins.blink-lib not found; did you include its overlay?");
        };
      });
    };

    checks = forAllSystems (system: mapAttrs' (n: nameValuePair "package-${n}") self.packages.${system});
  };
}

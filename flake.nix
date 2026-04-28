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
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [blink-lib.overlays.default];
      });

    version = "1.10.2";
    blink-cmp-package = {
      git,
      rust-jemalloc-sys,
      rustPlatform,
      stdenv,
      vimPlugins,
      vimUtils,
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

        dependencies = [
          (vimPlugins.blink-lib or (throw "vimPlugins.blink-lib not found; did you include its overlay?"))
        ];

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
      blink-cmp = nixpkgsFor.${system}.callPackage blink-cmp-package {};
      default = blink-cmp;
    });

    overlays.default = final: prev: {
      vimPlugins = prev.vimPlugins.extend (_: _: {
        blink-cmp = final.callPackage blink-cmp-package {};
      });
    };

    checks = forAllSystems (system: mapAttrs' (n: nameValuePair "package-${n}") (removeAttrs self.packages.${system} ["default"]));
  };
}

{
  description = "Performant, batteries-included completion plugin for Neovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    blink-lib.url = "github:saghen/blink.lib";
    blink-lib.inputs.nixpkgs.follows = "nixpkgs";
    blink-lib.inputs.flake-parts.follows = "flake-parts";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          self',
          inputs',
          pkgs,
          lib,
          ...
        }:
        {
          packages =
            let
              fs = lib.fileset;
              nixFs = fs.fileFilter (file: file.hasExt == "nix") ./.;
              rustFs = fs.unions [
                (fs.fileFilter (file: lib.hasPrefix "Cargo" file.name) ./.)
                (fs.fileFilter (file: file.hasExt "rs") ./.)
                ./.cargo
              ];
              nvimFs = fs.difference ./. (
                fs.unions [
                  nixFs
                  rustFs
                  ./doc
                  ./repro.lua
                ]
              );
              version = "1.10.0";
            in
            {
              blink-fuzzy-lib = pkgs.rustPlatform.buildRustPackage {
                pname = "blink-fuzzy-lib";
                inherit version;
                src = fs.toSource {
                  root = ./.;
                  fileset = rustFs;
                };
                cargoLock.lockFile = ./Cargo.lock;
                buildInputs = with pkgs; lib.optionals stdenv.hostPlatform.isAarch64 [ rust-jemalloc-sys ];
                nativeBuildInputs = with pkgs; [ git ];
              };

              blink-cmp = pkgs.vimUtils.buildVimPlugin {
                pname = "blink.cmp";
                inherit version;
                src = fs.toSource {
                  root = ./.;
                  fileset = nvimFs;
                };
                dependencies = [ inputs'.blink-lib.packages.blink-lib ];
                preInstall = ''
                  mkdir -p lib
                  ln -s ${self'.packages.blink-fuzzy-lib}/lib/libblink_cmp_fuzzy.* lib/
                '';
              };

              default = self'.packages.blink-cmp;
            };
        };
    };
}

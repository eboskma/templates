{
  description = "A flake for a Rust application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.git-hooks.flakeModule

        ./nix/hello-ferris.nix
      ];

      perSystem =
        {
          config,
          self',
          pkgs,
          system,
          ...
        }:
        let
          overlays = [
            inputs.rust-overlay.overlays.default
          ];

          # Use one of these methods to pull in a Rust toolchain
          # Use the default stable Rust
          # rustToolchain = pkgs.rust-bin.stable.stable.default;
          # Modify the toolchain to add components, targets, etc.n
          rustToolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [
              "rustfmt"
              "clippy"
            ];
          };
          # Use a rust-toolchain.toml to configure the toolchain
          # rustToolchain =
          #   (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);

          crane-lib = (inputs.crane.mkLib pkgs).overrideToolchain rustToolchain;
          pname = "hello-ferris";
          version = "0.1.0";
          src = crane-lib.cleanCargoSource ./..;
          buildInputs = with pkgs; [ ] ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.libiconv ];

          nativeBuildInputs = with pkgs; [ pkgconf ];

          cargoArtifacts = crane-lib.buildDepsOnly {
            inherit
              src
              buildInputs
              nativeBuildInputs
              pname
              version
              ;
          };

          hello-ferris = crane-lib.buildPackage {
            inherit
              cargoArtifacts
              src
              buildInputs
              nativeBuildInputs
              pname
              version
              ;
          };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs { inherit system overlays; };
          formatter = pkgs.nixpkgs-fmt;

          packages = {
            inherit hello-ferris;
          };
          packages.default = self'.packages.hello-ferris;

          checks = {
            inherit hello-ferris;

            hello-ferris-clippy = crane-lib.cargoClippy {
              inherit
                cargoArtifacts
                src
                buildInputs
                nativeBuildInputs
                pname
                version
                ;
              cargoClippyExtraArgs = "--all-targets -- --deny warnings";
            };

            hello-ferris-fmt = crane-lib.cargoFmt { inherit src pname version; };
          };
          pre-commit = {
            settings = {
              hooks = {
                nixfmt.enable = true;
                statix.enable = true;
                deadnix.enable = true;
                rust-overlay-clippy = {
                  enable = true;
                  name = "rust-overlay clippy";
                  entry = "${rustToolchain}/bin/cargo-clippy clippy";
                  files = "\\.rs$";
                  excludes = [ "^$" ];
                  types = [ "file" ];
                  types_or = [ ];
                  language = "system";
                  pass_filenames = false;
                };
              };
            };
          };

          treefmt = {
            projectRootFile = "flake.lock";

            programs = {
              nixfmt.enable = true;
              statix.enable = true;
              deadnix.enable = true;
              rustfmt.enable = true;
            };
          };

          devShells.default =
            with pkgs;
            mkShell {
              # inputsFrom = [ config.packages.hello-ferris ];
              packages = [
                rustToolchain
                cargo-edit
                cargo-diet
                cargo-feature
                cargo-outdated
                pre-commit
                rust-analyzer
              ];
              shellHook = ''
                ${config.pre-commit.installationScript}
              '';
            };
        };
    };
}

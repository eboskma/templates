{
  description = "A flake for a Rust application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, pre-commit-hooks, crane, flake-compat }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        # Use one of these methods to pull in a Rust toolchain
        # Use the default stable Rust
        # rustToolchain = pkgs.rust-bin.stable.stable.default;
        # Modify the toolchain to add components, targets, etc.n
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rustfmt" "clippy" ];
          targets = [ "thumbv7m-none-eabi" ];
        };
        # Use a rust-toolchain.toml to configure the toolchain
        # rustToolchain =
        #   (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);

        crane-lib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
        src = crane-lib.cleanCargoSource ./.;
        buildInputs = with pkgs; [
        ] ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.libiconv ];

        nativeBuildInputs = with pkgs; [
          pkgconf
        ];

        cargoArtifacts = crane-lib.buildDepsOnly {
          inherit src buildInputs nativeBuildInputs;
        };

        hello-ferris = crane-lib.buildPackage {
          inherit cargoArtifacts src buildInputs nativeBuildInputs;
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        packages = {
          inherit hello-ferris;
        };
        packages.default = self.packages.${system}.hello-ferris;

        apps.hello-ferris = flake-utils.lib.mkApp {
          drv = self.packages."${system}".default;
        };
        apps.default = self.apps.${system}.hello-ferris;

        overlays = final: prev: {
          hello-ferris = self.packages.${system}.hello-ferris;
        };

        checks = {
          inherit hello-ferris;

          hello-ferris-clippy = crane-lib.cargoClippy {
            inherit cargoArtifacts src buildInputs nativeBuildInputs;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          };

          hello-ferris-fmt = crane-lib.cargoFmt {
            inherit src;
          };

          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
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

        devShells.default = with pkgs; mkShell {
          name = "hello-ferris";
          # inputsFrom = [ self.packages.${system}.hello-ferris ];
          packages = [ rustToolchain cargo-edit cargo-diet cargo-feature cargo-outdated pre-commit rust-analyzer ];
        };

      });

}

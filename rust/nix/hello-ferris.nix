{ inputs, ... }:
{
  perSystem = { config, self', pkgs, system, ... }:
    let
      overlays = [ (import inputs.rust-overlay) ];

      # Use one of these methods to pull in a Rust toolchain
      # Use the default stable Rust
      # rustToolchain = pkgs.rust-bin.stable.stable.default;
      # Modify the toolchain to add components, targets, etc.n
      rustToolchain = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rustfmt" "clippy" ];
      };
      # Use a rust-toolchain.toml to configure the toolchain
      # rustToolchain =
      #   (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);

      crane-lib = (inputs.crane.mkLib pkgs).overrideToolchain rustToolchain;
      pname = "hello-ferris";
      version = "0.1.0";
      src = crane-lib.cleanCargoSource ./..;
      buildInputs = with pkgs; [
      ] ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.libiconv ];

      nativeBuildInputs = with pkgs; [
        pkgconf
      ];

      cargoArtifacts = crane-lib.buildDepsOnly {
        inherit src buildInputs nativeBuildInputs pname version;
      };

      hello-ferris = crane-lib.buildPackage {
        inherit cargoArtifacts src buildInputs nativeBuildInputs pname version;
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
          inherit cargoArtifacts src buildInputs nativeBuildInputs pname version;
          cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        };

        hello-ferris-fmt = crane-lib.cargoFmt {
          inherit src pname version;
        };

      };
      pre-commit = {
        check.enable = true;
        devShell = self'.devShells.default;
        settings = {
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

      devShells.hello-ferris = with pkgs; mkShell {
        name = "hello-ferris";
        # inputsFrom = [ self.packages.${system}.hello-ferris ];
        packages = [ rustToolchain cargo-edit cargo-diet cargo-feature cargo-outdated pre-commit rust-analyzer ];
        shellHook = ''
          ${config.pre-commit.installationScript}
        '';
      };
    };
}

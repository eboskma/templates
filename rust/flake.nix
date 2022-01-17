{
  description = "A flake for a Rust application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nmattia/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };
  };

  outputs = { self, nixpkgs, utils, naersk, rust-overlay }:
    utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        naersk-lib = pkgs.callPackage naersk { };

        # Use one of these methods to pull in a Rust toolchain
        # Use the default stable Rust 
        # rustToolchain = pkgs.rust-bin.stable.default;
        # Modify the toolchain to add components, targets, etc.
        rustToolchain = pkgs.rust-bin.stable.default.override {
          extensions = [ "rustfmt" "clippy" ];
          targets = [ "thumbv7m-none-eabi" ];
        };
        # Use a rust-toolchain.toml to configure the toolchain
        # rustToolchain = 
        #   (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);

        buildInputs = [
          rustToolchain
        ];
        nativeBuildInputs = [
        ];
      in
      rec {
        packages.hello-ferris = naersk-lib.buildPackage
          {
            inherit buildInputs nativeBuildInputs;
            root = ./.;
          };
        defaultPackage = packages.hello-ferris;

        apps.hello-ferris = utils.lib.mkApp {
          drv = self.defaultPackage."${system}";
        };
        defaultApp = apps.hello-ferris;

        overlays = final: prev: {
          hello-ferris = packages.hello-ferris;
        };

        devShell = with pkgs; mkShell {
          inherit buildInputs;
          nativeBuildInputs = [ cargo-edit cargo-diet cargo-feature cargo-outdated pre-commit rust-analyzer ] ++ nativeBuildInputs;
        };

      });

}

{
  description = "A flake for a Rust application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    naersk = {
      url = "github:nmattia/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, naersk, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        naersk-lib = pkgs.callPackage naersk { };

        # Use one of these methods to pull in a Rust toolchain
        # Use the default stable Rust 
        # rustToolchain = pkgs.rust-bin.stable.stable.default;
        # Modify the toolchain to add components, targets, etc.
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
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
      {
        formatter = pkgs.nixpkgs-fmt;

        packages.hello-ferris = naersk-lib.buildPackage
          {
            inherit buildInputs nativeBuildInputs;
            root = ./.;
          };
        packages.default = self.packages.${system}.hello-ferris;

        apps.hello-ferris = flake-utils.lib.mkApp {
          drv = self.packages."${system}".default;
        };
        apps.default = self.apps.${system}.hello-ferris;

        overlays = final: prev: {
          hello-ferris = self.packages.${system}.hello-ferris;
        };

        devShells.default = with pkgs; mkShell {
          inherit buildInputs;
          nativeBuildInputs = [ cargo-edit cargo-diet cargo-feature cargo-outdated pre-commit rust-analyzer ] ++ nativeBuildInputs;
        };

      });

}

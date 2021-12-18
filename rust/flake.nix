{
  description = "A flake for a Rust application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nmattia/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };

        buildInputs = [
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
          inherit nativeBuildInputs;

          buildInputs = [ cargo cargo-edit cargo-diet cargo-feature cargo-outdated rustc rustfmt pre-commit rustPackages.clippy ] ++ buildInputs;
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
        };

      });

}

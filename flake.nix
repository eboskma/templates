{
  description = "A collection of flake templates";

  outputs = { self, nixpkgs }: {

    templates = {

      elixir = {
        path = ./elixir;
        description = "A basic flake for elixir development";
      };

      phoenix = {
        path = ./phoenix;
        description = "A flake for developing Phoenix projects";
      };

      rust = {
        path = ./rust;
        description = "A flake for Rust projects";
      };

      meson = {
        path = ./meson;
        description = "A basic flake for projects using meson";
      };

    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

  };
}

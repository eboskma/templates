{
  description = "A collection of flake templates";

  outputs = { self, nixpkgs }: {

    templates = {

      base = {
        path = ./base;
        description = "An empty flake with a devShell, useful as a starting point.";
      };

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

      lisp = {
        path = ./lisp;
        description = "A flake for sbcl";
      };

    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

  };
}

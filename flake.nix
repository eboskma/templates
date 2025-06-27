{
  description = "A collection of flake templates";

  outputs =
    { nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {

      templates = {

        base = {
          path = ./base;
          description = "An empty flake with a devShell, useful as a starting point.";
        };

        elixir = {
          path = ./elixir;
          description = "A basic flake for elixir development";
        };

        gleam = {
          path = ./gleam;
          description = "A flake to build Gleam applications";
        };

        go = {
          path = ./go;
          description = "A flake for developing Go software";
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

        racket = {
          path = ./racket;
          description = "A flake with a Racket devshell";
        };

        livebook = {
          path = ./livebook;
          description = "A flake to run Elixir Livebook";
        };

        zig = {
          path = ./zig;
          description = "A flake to develop your next zig app";
        };
      };

      formatter.x86_64-linux = pkgs.nixfmt-rfc-style;

      devShells.x86_64-linux.default =
        with pkgs;
        mkShell {
          name = "flake-templates";
          packages = [ taplo ];
        };
    };
}

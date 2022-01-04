{
  description = "A collection of flake templates";

  outputs = { self }: {

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

    };

    defaultTemplate = self.templates.trivial;

  };
}

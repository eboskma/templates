{
  perSystem = { pkgs, ... }: {
    devShells.default =
      pkgs.devshell.mkShell {
        packages = with pkgs; [
          erlang
          libnotify
          inotify-tools
          elixir_ls
        ];

        env = [
          {
            name = "HEX_HOME";
            eval = ''''${PWD}/.nix/hex'';
          }
          {
            name = "MIX_HOME";
            eval = ''''${PWD}/.nix/mix'';
          }
          {
            name = "PATH";
            prefix = ''''${MIX_HOME}/escripts'';
          }
          {
            name = "ERL_AFLAGS";
            value = "-kernel shell_history enabled";
          }
        ];

        commands = [
          {
            name = "mix";
            package = "elixir";
            help = "mix";
          }
        ];
      };
  };
}

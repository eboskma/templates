{
  perSystem =
    { inputs', pkgs, ... }:
    {
      devshells.default = {
        packages = with pkgs; [
          elixir
          erlang
          lexical
          libnotify
          inotify-tools

        ];

        env = [
          {
            name = "HEX_HOME";
            eval = "\${PWD}/.nix/hex";
          }
          {
            name = "MIX_HOME";
            eval = "\${PWD}/.nix/mix";
          }
          {
            name = "PATH";
            prefix = "\${MIX_HOME}/escripts";
          }
          {
            name = "ERL_AFLAGS";
            value = "-kernel shell_history enabled";
          }
        ];

        commands = [
          {
            name = "mix";
            package = pkgs.elixir;
            help = "mix";
          }
        ];
      };
    };
}

{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.zls = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "zls";
        version = "0.13.0";

        src = pkgs.fetchFromGitHub {
          owner = "zigtools";
          repo = "zls";
          rev = finalAttrs.version;
          fetchSubmodules = true;
          hash = "sha256-vkFGoKCYUk6B40XW2T/pdhir2wzN1kpFmlLcoLwJx1U=";
        };

        langref = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/ziglang/zig/cf90dfd3098bef5b3c22d5ab026173b3c357f2dd/doc/langref.html.in";
          hash = "sha256-XUP1mfVqHuAkaVhVJUXRPuTd63xwXAWkMlVNXv9uGQI=";
        };

        zigBuildFlags = [ "-Dversion_data_path=${finalAttrs.langref}" ];

        nativeBuildInputs = [ pkgs.zig_0_13.hook ];

        postPatch = ''
          ln -s ${pkgs.callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
        '';

        meta = {
          description = "Zig LSP implementation + Zig Language Server";
          mainProgram = "zls";
          changelog = "https://github.com/zigtools/zls/releases/tag/${finalAttrs.version}";
          homepage = "https://github.com/zigtools/zls";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [
            figsoda
            moni
          ];
          platforms = lib.platforms.unix;
        };
      });
    };
}

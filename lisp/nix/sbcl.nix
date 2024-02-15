{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkPackageOption;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { config, pkgs, ... }:
      {
        options.sbcl = {
          package = mkPackageOption pkgs "sbcl" { };
        };

        config.packages = {
          rsbcl = pkgs.writeShellApplication {
            name = "rsbcl";

            runtimeInputs = with pkgs; [
              rlwrap
              config.sbcl.package
              config.packages.sbcl-gen-completions
            ];

            text = ''
              BREAK_CHARS="(){}[],^%$#@\"\";\'\'|\\"

              if [[ $# -eq 0 ]]; then
                if [[ ''${TERM} == "dumb" ]]; then
                  exec sbcl
                else
                  sbcl-gen-completions
                  rlwrap --remember --history-filename="''${HOME}/.sbcl_history" --histsize=1000000 --complete-filenames --break-chars="''${BREAK_CHARS}" --file="''${HOME}/.sbcl_completions" sbcl
                fi
              else
                exec sbcl --script "$@"
              fi
            '';
          };

          sbcl-gen-completions =
            let
              loadSystems = builtins.concatStringsSep "\n" (
                map (p: "(asdf:load-system '${p.pname})") config.sbcl.package.lispLibs
              );
            in
            pkgs.writeScriptBin "sbcl-gen-completions" ''
              #!${config.sbcl.package}/bin/sbcl --script
              (load (sb-ext:posix-getenv "ASDF"))
              ${loadSystems}
              (let (symbols)
                (do-all-symbols (sym)
                  (let ((package (symbol-package sym)))
                    (cond
                      ((not (fboundp sym)))
                      ((or (eql #.(find-package :cl) package)
                           (eql #.(find-package :cl-user) package))
                        (pushnew (symbol-name sym) symbols))
                      ((eql #.(find-package :keyword) package)
                        (pushnew (concatenate 'string ":" (symbol-name sym)) symbols))
                      (package
                        (pushnew (concatenate 'string (package-name package)
                                              ":"
                                              (symbol-name sym))
                                 symbols)))))
                (with-open-file (output #.(concatenate 'string (posix-getenv "HOME")
                                                       "/.sbcl_completions")
                                        :direction :output :if-exists :overwrite
                                        :if-does-not-exist :create)
                  (format output "~{~(~A~)~%~}" (sort symbols #'string<))))
            '';
        };
      }
    );
  };
}

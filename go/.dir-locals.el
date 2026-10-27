;;; Directory Local Variables         -*- no-byte-compile: t; -*-
;;; For more information see (info "(emacs) Directory Variables")

((go-mode . ((eglot-workspace-configuration
	      . (:gopls (:usePlaceholders t
			 :staticcheck t
			 :hints (:assignVariableTypes t
				 :compositeLiteralFields t
				 :compositeLiteralTypes t
				 :constantValues t
				 :functionTypeParameters t
				 :ignoredError t
				 :parameterNames t
				 :rangeVariableTypes t)))))))

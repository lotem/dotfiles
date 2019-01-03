(prelude-require-package 'google-c-style)

(setq prelude-c-mode-common-hook '(google-set-c-style
                                   google-make-newline-indent))

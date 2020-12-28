;; https://mirrors.ustc.edu.cn/help/elpa.html
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "https://mirrors.ustc.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))

(prelude-require-package 'ripgrep)

;; set the default font
(set-face-attribute 'default nil
                    :family "Iosevka Slab"
                    :slant 'normal
                    :weight 'light
                    :height 120)

;; do not hightlight long lines
(setq whitespace-style '(face tabs empty trailing))

(require 'server)
(unless (server-running-p) (server-start))

;; https://mirrors.tuna.tsinghua.edu.cn/help/elpa/
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

;; https://mirrors.ustc.edu.cn/help/elpa.html
;; (setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
;;                          ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
;;                          ("melpa-stable" . "https://mirrors.ustc.edu.cn/elpa/melpa-stable/")
;;                          ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))

(prelude-require-package 'ripgrep)

;; set the default font
(set-face-attribute 'default nil
                    :family "Iosevka"
                    :slant 'normal
                    :weight 'normal
                    :width 'normal
                    :height 180)

(set-face-attribute 'fixed-pitch nil
                    :family "Iosevka"
                    :slant 'normal
                    :weight 'normal
                    :width 'expanded
                    :height 180)

;; do not highlight long lines
(setq whitespace-style '(face tabs empty trailing))

(require 'server)
(unless (server-running-p) (server-start))

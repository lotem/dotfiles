(prelude-require-package 'github-theme)
(prelude-require-package 'snazzy-theme)
(load-theme 'github t)

;; set the default font
(set-face-attribute 'default nil
                    :family "Iosevka"
                    :slant 'normal
                    :weight 'light
                    :height 240)

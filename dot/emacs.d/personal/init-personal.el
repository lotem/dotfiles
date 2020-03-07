;; https://mirrors.ustc.edu.cn/help/elpa.html
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "https://mirrors.ustc.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))

(prelude-require-package 'ripgrep)

(prelude-require-package 'github-theme)
(prelude-require-package 'snazzy-theme)
;; last t is for NO-ENABLE
;; (load-theme 'github t t)
;; (load-theme 'snazzy t t)

;; (defun mb/pick-color-theme (frame)
;;   (select-frame frame)
;;   (if (window-system frame)
;;       (progn
;;         (disable-theme 'snazzy) ; in case it was active
;;         (enable-theme 'github))
;;     (progn
;;       (disable-theme 'github) ; in case it was active
;;       (enable-theme 'snazzy))))
;; (add-hook 'after-make-frame-functions 'mb/pick-color-theme)

;; For when started with emacs or emacs -nw rather than emacs --daemon
;; (if window-system
;;     (enable-theme 'github)
;;   (enable-theme 'snazzy))

;; set the default font
(set-face-attribute 'default nil
                    :family "Iosevka"
                    :slant 'normal
                    :weight 'light
                    :height 200)

(require 'server)
(unless (server-running-p) (server-start))

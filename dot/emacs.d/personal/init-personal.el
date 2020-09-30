;; https://mirrors.ustc.edu.cn/help/elpa.html
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "https://mirrors.ustc.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))

(prelude-require-package 'ripgrep)

;; (prelude-require-package 'github-theme)
;; (prelude-require-package 'leuven-theme)
(prelude-require-package 'minimal-theme)
;; (prelude-require-package 'monokai-theme)
;; (prelude-require-package 'snazzy-theme)

;; last t is for NO-ENABLE
(load-theme 'minimal t t)
(load-theme 'minimal-light t t)

(defun mb/pick-color-theme (frame)
  (select-frame frame)
  (if (window-system frame)
      (progn
        (disable-theme 'minimal) ; in case it was active
        (enable-theme 'minimal-light))
    (progn
      (disable-theme 'minimal-light) ; in case it was active
      (enable-theme 'minimal))))
(add-hook 'after-make-frame-functions 'mb/pick-color-theme)

;; For when started with emacs or emacs -nw rather than emacs --daemon
(if window-system
    (enable-theme 'minimal-light)
  (enable-theme 'minimal))

;; set the default font
(set-face-attribute 'default nil
                    :family "Iosevka Slab"
                    :slant 'normal
                    :weight 'light
                    :height 120)

(require 'server)
(unless (server-running-p) (server-start))

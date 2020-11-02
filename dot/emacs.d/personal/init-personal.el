;; https://mirrors.ustc.edu.cn/help/elpa.html
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "https://mirrors.ustc.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))

(prelude-require-package 'ripgrep)

(prelude-require-package 'almost-mono-themes)
;; (prelude-require-package 'github-theme)
;; (prelude-require-package 'leuven-theme)
;; (prelude-require-package 'minimal-theme)
;; (prelude-require-package 'monokai-theme)
;; (prelude-require-package 'snazzy-theme)

;; last t is for NO-ENABLE
(load-theme 'almost-mono-black t t)
(load-theme 'almost-mono-white t t)

(defun mb/pick-color-theme (frame)
  (select-frame frame)
  (if (window-system frame)
      (progn
        (disable-theme 'almost-mono-black) ; in case it was active
        (enable-theme 'almost-mono-white))
    (progn
      (disable-theme 'almost-mono-white) ; in case it was active
      (enable-theme 'almost-mono-black))))
(add-hook 'after-make-frame-functions 'mb/pick-color-theme)

;; For when started with emacs or emacs -nw rather than emacs --daemon
(if window-system
    (enable-theme 'almost-mono-white)
  (enable-theme 'almost-mono-black))

;; set the default font
(set-face-attribute 'default nil
                    :family "Iosevka Slab"
                    :slant 'normal
                    :weight 'light
                    :height 120)

(require 'server)
(unless (server-running-p) (server-start))

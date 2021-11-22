(defun pick-color-theme (window-theme terminal-theme)
  ;; last t is for NO-ENABLE
  (load-theme window-theme t t)
  (load-theme terminal-theme t t)

  (defun mb/pick-color-theme (frame)
    (select-frame frame)
    (if (window-system frame)
        (progn
          (disable-theme terminal-theme) ; in case it was active
          (enable-theme window-theme))
      (progn
        (disable-theme window-theme) ; in case it was active
        (enable-theme terminal-theme))))
  (add-hook 'after-make-frame-functions 'mb/pick-color-theme)

  ;; For when started with emacs or emacs -nw rather than emacs --daemon
  (if window-system
      (enable-theme window-theme)
    (enable-theme terminal-theme)))

(prelude-require-package 'doom-themes)
(load-theme 'doom-monokai-classic t)
;; (pick-color-theme 'doom-one-light 'doom-one)

(require-package 'company-racer)
(require-package 'racer)
(require-package 'flycheck-rust)
(require-package 'rust-mode)

;; Enable company globally for all mode
(global-company-mode)

;; Reduce the time after which the company auto completion popup opens
(setq company-idle-delay 0.2)

;; Reduce the number of characters before company kicks in
(setq company-minimum-prefix-length 1)
;; Set path to racer binary
(setq racer-cmd (expand-file-name "~/.cargo/bin/racer"))

;; Set path to rust src directory
(setq racer-rust-src-path (expand-file-name "~/.rustup/toolchains/nightly-x86_64-apple-darwin/lib/rustlib/src/rust/src"))

;; Load rust-mode when you open `.rs` files
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

;; Setting up configurations when you load rust-mode
(add-hook 'rust-mode-hook

          '(lambda ()
             ;; Enable racer
             (racer-activate)

             ;; Hook in racer with eldoc to provide documentation
             (racer-turn-on-eldoc)

             ;; Use flycheck-rust in rust-mode
             (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)

             ;; Use company-racer in rust mode
             (set (make-local-variable 'company-backends) '(company-racer))

             ;; Key binding to jump to method definition
             (local-set-key (kbd "M-.") #'racer-find-definition)

             ;; Key binding to auto complete and indent
             (local-set-key (kbd "TAB") #'racer-complete-or-indent)))

;;; org-page
;;(require-package 'org-page)
;;(require 'org-page)
;;(setq op/repository-directory "~/org")
;;(setq op/site-domain "http://sst.rime.im/")
;;(setq op/personal-disqus-shortname "zzsst")
;;(setq op/personal-duoshuo-shortname "zzsst")

(require-package 'google-c-style)
(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

(add-hook 'c-mode-common-hook
          (lambda()
            (local-set-key  (kbd "C-c o") 'ff-find-other-file)))

(provide 'init-local)

(load-theme 'manoj-dark)
;; Make all commands of the "package" module present
(require 'package)

;; Set internet repositories
(setq package-archives '(("org"       . "http://orgmode.org/elpa/") 
			 ("gnu"       . "http://elpa.gnu.org/packages/") 
			 ("melpa"     . "http://melpa.org/packages/")))

;; Get package to work
(package-initialize)
;; Dirty fix for signature check failure
(setq package-check-signature nil)

(defun set-use-packages () 
  "Setup used packages"
  ;; auto-complete
  (use-package 
    auto-complete 
    :config (ac-config-default) 
    (setq ac-disable-faces nil) 
    (global-auto-complete-mode t)) 
  (use-package 
    magit 
    :bind (("C-x g" . magit))) 
  (use-package 
    elisp-format))

(defun init () 
  "Initialize basic config"
  ;; Disable startup screen
  (setq inhibit-startup-screen t)
  ;; Disable tool-bar
  (menu-bar-mode 0) 
  (tool-bar-mode 0) 
  (scroll-bar-mode 0)
  ;; Show line numbers and format
  (global-display-line-numbers-mode t) 
  (setq linum-format "%d ")
  ;; Autoclose brackets
  (show-paren-mode 1) 
  (electric-pair-mode t)
  ;; Switch buffers quickly with C-b <target-buffer>
  (ido-mode 1))

;; declare hooks
(defun shell-format-on-save () 
  "run shfmt on save while in sh mode"
  (when (eq major-mode 'sh-mode) 
    (shell-command-to-string (format "shfmt -i 2 -bn -w %s" buffer-file-name))
    ;; TODO: is it possible to output shellcheck output to seperate buffer??
    (message (shell-command-to-string (format "shellcheck %s" buffer-file-name))) 
    (revert-buffer 
     :ignore-auto 
     :noconfirm)))

(defun elisp-format-on-save () 
  "run elisp-format on save while in Emacs lisp mode"
  (when (eq major-mode 'emacs-lisp-mode) 
    (elisp-format-buffer)))

;; initialize hooks
(add-hook 'after-save-hook #'shell-format-on-save)
(add-hook 'after-save-hook #'elisp-format-on-save)

(if (string-match "waw" system-name) 
    (progn
      ;; Load packages manually
      ;; TODO: Load manually all packages that are stored in elpa_backup directory
      (message "Remote Server Setup")) 
  (progn
    ;; Setup package autoloads, keybindings, and various mode configuration
    (package-refresh-contents) 
    (unless (package-installed-p 'use-package) 
      (package-install 'use-package)) 
    (require 'use-package) 
    (set-use-packages)))

(init)

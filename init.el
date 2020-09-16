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
  "SETUP USED PACKAGES."
  ;; auto-complete
  (use-package 
    company) 
  (use-package 
    flycheck) 
  (use-package 
    ag) 
  (use-package 
    auto-complete 
    :config (ac-config-default) 
    (setq ac-disable-faces nil) 
    (global-auto-complete-mode t)) 
  (use-package 
    magit 
    :bind (("C-x g" . magit))) 
  (use-package 
    elisp-format) 
  (use-package 
    haskell-mode) 
  (use-package 
    python-mode))
(defun init () 
  "INITIALIZE BASIC CONFIG."
  ;; Disable startup screen
  (setq inhibit-startup-screen t)
  ;; Fix flycheck lags
  (setq flycheck-check-syntax-automatically '(save mode-enable))
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
;; TODO: there is for sure a more generic approach for generating hooks, in which
;; we would be able to pass mode as a parameter and another function as second parameter
(defun shell-format-on-save () 
  "RUN SHFMT ON SAVE WHILE IN 'SH-MODE'."
  (when (eq major-mode 'sh-mode) 
    (shell-command-to-string (format "shfmt -i 2 -bn -w %s" buffer-file-name))
    ;; TODO: is it possible to output shellcheck output to seperate buffer??
    (message (shell-command-to-string (format "shellcheck %s" buffer-file-name))) 
    (revert-buffer 
     :ignore-auto 
     :noconfirm)) 
  (message(format "%s formatted!" buffer-file-name)))

(defun python-format-on-save () 
  "RUN AUTOPEP8 ON SAVE WHILE IN `'PYTHON-MODE`."
  (when (eq major-mode 'python-mode) 
    (shell-command-to-string (format "autopep8 --in-place --aggressive
--aggressive %s" buffer-file-name)) 
    (revert-buffer 
     :ignore-auto 
     :noconfirm)) 
  (message (format "%s formatted!" buffer-file-name)))

(defun elisp-format-on-save () 
  "RUN ELISP-FORMAT ON SAVE WHILE IN `EMACS-LISP-MODE`."
  (when (eq major-mode 'emacs-lisp-mode) 
    (elisp-format-buffer)) 
  (message (format "%s formatted!" buffer-file-name)))

;; initialize hooks
(add-hook 'after-save-hook #'shell-format-on-save)
(add-hook 'after-save-hook #'elisp-format-on-save)
(add-hook 'after-save-hook #'python-format-on-save)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'flycheck-mode)
(add-hook 'sh-mode-hook 'flycheck-mode)
(add-hook 'c-mode-hook 'flycheck-mode)
(add-hook 'c++-mode-hook 'flycheck-mode)
(add-hook 'emacs-lisp-mode-hook 'flycheck-mode)
(add-hook 'python-mode-hook 'flycheck-mode)
(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'c++-mode-hook (lambda () 
			   (set (make-local-variable 'compile-command) 
				(format "g++ -g -Wall -O0 -std=c++11 %s" (buffer-name)))))


(if (string-match "waw" system-name) 
    (progn
      ;; Load packages manually
      ;; TODO: Load manually all packages that are stored in elpa_backup directory
      (message "Remote Server Setup")) 
  (progn
    ;; Setup package autoloads, keybindings, and various mode configuration
    ;; (package-refresh-contents)
    (unless (package-installed-p 'use-package) 
      (package-install 'use-package)) 
    (require 'use-package) 
    (set-use-packages)))

(init)

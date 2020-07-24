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
  (use-package auto-complete
	       :config
	       (ac-config-default)
	       (setq ac-disable-faces nil)
	       (global-auto-complete-mode t))
  ;; git-gutter setup
  (use-package git-gutter
	       :config
	       (global-git-gutter-mode t)
	       ;; If you would like to use git-gutter.el and linum-mode
	       (git-gutter:linum-setup)
	       ;; If you enable git-gutter-mode for some modes
	       (global-set-key (kbd "C-x C-g") 'git-gutter)
	       (global-set-key (kbd "C-x v =") 'git-gutter:popup-hunk)
	       ;; Jump to next/previous hunk
	       (global-set-key (kbd "C-x p") 'git-gutter:previous-hunk)
	       (global-set-key (kbd "C-x n") 'git-gutter:next-hunk)
	       ;; Stage current hunk
	       (global-set-key (kbd "C-x v s") 'git-gutter:stage-hunk)
	       ;; Revert current hunk
	       (global-set-key (kbd "C-x v r") 'git-gutter:revert-hunk)
	       ;; Mark current hunk
	       (global-set-key (kbd "C-x v SPC") #'git-gutter:mark-hunk)))

(defun init ()
  "Initialize basic config"
  ;; Disable startup screen
  (setq inhibit-startup-screen t)
  ;; Disable tool-bar
  (menu-bar-mode 0)
  ;; Disable menu-bar and scroll-bar when emacs is in gui mode(OSX)
  ;; Show line numbers and format
  (global-linum-mode t)
  (setq linum-format "%d ")
  ;; Autoclose brackets
  (show-paren-mode 1)
  (electric-pair-mode t)
  ;; Switch buffers quickly with C-b <target-buffer>
  (ido-mode 1)
)

;; declare hooks
(defun shell-format-on-save ()
  "run shfmt on save while in sh mode"
  (when (eq major-mode 'sh-mode)
    (shell-command-to-string (format "shfmt -i 2 -bn -w %s" buffer-file-name))
    ;; TODO: is it possible to output shellcheck output to seperate buffer??
    (message (shell-command-to-string (format "shellcheck %s" buffer-file-name)))
    (revert-buffer :ignore-auto :noconfirm)))

;; initialize hooks
(add-hook 'after-save-hook #'shell-format-on-save)

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

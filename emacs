;;;; jkpl's Emacs confs

;; Common Lisp compatibility
(require 'cl)

;; Disable backup and autosave
(setq backup-inhibited t)
(setq auto-save-default nil)

;; Custom envs
(setenv "PAGER" "/bin/cat")

;; Load paths
(add-to-list 'load-path "~/.emacs.d/")

;; Version specific settings
(if (>= emacs-major-version 24)
  (progn ;; Emacs 24 and newer
    (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/"))
  (progn ;; Emacs 23 and older
    (add-to-list 'load-path "~/.emacs.d/package/")))

;; Package management
(setq my-pkgs
  '(evil popup sws-mode auto-complete surround magit lua-mode
         haskell-mode jade-mode coffee-mode markdown-mode
         python stylus-mode js2-mode undo-tree tango-2-theme
         flymake-coffee flymake-jslint))
(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

;; Custom functions
(defun install-missing-packages ()
  "Installs all the missing packages"
  (interactive)
  (mapc
    (lambda (pkg)
      (or (package-installed-p pkg)
          (if (y-or-n-p (format "Package %s is missing. Install it? " pkg))
            (package-install pkg)))) my-pkgs))

(defun kr-or-bwkw (&optional arg region)
  "`kill-region` if the region is active, otherwise `backward-kill-word`"
  (interactive (list (prefix-numeric-value current-prefix-arg) (use-region-p)))
  (if region
      (kill-region (region-beginning) (region-end))
    (backward-kill-word arg)))

(defun kr-or-kl (&optional arg region)
  "`kill-region` if the region is active, otherwise `kill-line`"
  (interactive (list (prefix-numeric-value current-prefix-arg) (use-region-p)))
  (if region
      (kill-region (region-beginning) (region-end))
    (kill-line arg)))

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

(defun jump-to-last-mark () (interactive) (set-mark-command 1))

;; Keybindings
(global-set-key (kbd "M-`") 'jump-to-last-mark)
(global-set-key (kbd "C-w") 'kr-or-bwkw)
(global-set-key (kbd "C-k") 'kr-or-kl)
(global-set-key (kbd "C-x C-k") 'kill-region)
(global-set-key (kbd "C-c q") 'auto-fill-mode)
(global-set-key (kbd "M-n") 'next-buffer)
(global-set-key (kbd "M-p") 'previous-buffer)
(global-set-key (kbd "C-c C-m") 'execute-extended-command)
(global-set-key (kbd "C-x C-m") 'execute-extended-command)
(global-set-key (kbd "C-z") 'keyboard-escape-quit)
(global-set-key (kbd "C-t") 'other-window)
(global-set-key (kbd "RET") 'indent-new-comment-line)
(global-set-key (kbd "C-j") 'newline)
(global-set-key (kbd "C-x C-j") 'join-line)

;; UI
(when (>= emacs-major-version 24)
  (load-theme 'tango-2 t))
(if (not window-system)
  (progn ;; No window system
    ;; (when (require 'mouse nil t)
    ;;   (xterm-mouse-mode t)
    ;;   (defun track-mouse (e))
    ;;   (setq mouse-sel-mode t))
    (menu-bar-mode -1)
    (set-face-background 'mode-line "#0000ee")
    (set-face-foreground 'mode-line "#ffffff")
    (set-face-background 'mode-line-inactive "#00005f")
    (set-face-foreground 'mode-line-inactive "#767676")
    (set-face-background 'default "#000000")
    (set-face-foreground 'default "#dadada"))
  (progn ;; Window system
    (set-cursor-color "#ffcc22")
    (set-mouse-color "#ffffff")))
(blink-cursor-mode 0)
(show-paren-mode (column-number-mode t))
(global-font-lock-mode t)
(transient-mark-mode t)
(setq inhibit-splash-screen t
      completion-cycle-threshold 10
      show-paren-delay 0.0)
(when (fboundp 'set-scroll-bar-mode) (set-scroll-bar-mode 'right))
(set-input-mode t nil t)

;; Winner mode
(winner-mode 1)

;; Aliases
(defalias 'yes-or-no-p 'y-or-n-p)
(defalias 'wins 'shrink-window)
(defalias 'wine 'enlarge-window)
(defalias 'winsh 'shrink-window-horizontally)
(defalias 'wineh 'enlarge-window-horizontally)

;; Some defaults
(setq-default
 tab-width 4
 c-basic-offset 4
 indent-tabs-mode nil
 fill-column 79)

;; Enable disabled commands
(put 'downcase-region 'disabled nil)

;; Filetype specific settings
(load "~/.emacs.d/ft")

;; Email
(setq message-send-mail-function 'message-send-mail-with-sendmail)
(setq sendmail-program "/usr/bin/msmtp")

;; Notmuch
(autoload 'notmuch "~/.emacs.d/my-notmuch" "notmuch mail" t)

;; IDO mode
(when (require 'ido nil t)
  (setq ido-enable-flex-matching t
        ido-everywhere t
        ido-case-fold t
        confirm-nonexistent-file-or-buffer nil
        ido-use-filename-at-point 'guess)
  (ido-mode 1)
  (define-key ido-common-completion-map (kbd "C-z") 'keyboard-escape-quit))

;; TRAMP
;; (if window-system
;;     (progn ;; For some strange reason, TRAMP doesn't work well with terminal.
;;       (setq tramp-default-method "scp"
;;             tramp-chunkzise 500
;;             tramp-shell-prompt-pattern "^[^$>\n]*[#$%>] *\\(\[[0-9;]*[a-zA-Z] *\\)*"))
;;   (setq tramp-mode nil))
(setq tramp-mode nil)

;; Browser
(when (not (getenv "DISPLAY"))
  (setq browse-url-browser-function 'w3m-browse-url)
  (autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t))
(setq w3m-use-cookies t
      w3m-coding-system 'utf-8
      w3m-file-coding-system 'utf-8
      w3m-file-name-coding-system 'utf-8
      w3m-input-coding-system 'utf-8
      w3m-output-coding-system 'utf-8
      w3m-terminal-coding-system 'utf-8)

;; Auto-complete
(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
  (ac-config-default)
  (setq ac-auto-start nil)
  (ac-set-trigger-key "TAB"))

;; EVIL
(when (require 'evil nil t)
  (evil-mode 1)
  (setq evil-default-state 'normal)
  (define-key evil-normal-state-map (kbd ";") 'evil-ex)
  (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)
  (define-key evil-normal-state-map (kbd "C-t") 'other-window)
  (define-key evil-normal-state-map (kbd "-") 'evil-window-decrease-height)
  (define-key evil-normal-state-map (kbd "+") 'evil-window-increase-height)

  ;; emacs mode as insert mode
  (setcdr evil-insert-state-map nil)
  (define-key evil-insert-state-map
    (read-kbd-macro evil-toggle-key) 'evil-emacs-state)
  (define-key evil-insert-state-map (kbd "C-z") 'evil-normal-state)
  (define-key evil-visual-state-map (kbd "C-z") 'evil-normal-state)
  (define-key evil-replace-state-map (kbd "C-z") 'evil-normal-state)

  ;; evil surround
  (when (require 'surround nil t)
    (global-surround-mode 1)))

;; Undo tree
(when (require 'undo-tree nil t)
  (global-set-key (kbd "M-?") 'undo-tree-redo))

;; Customizations file
(setq custom-file "~/.emacs.d/custom-file.el")
(load custom-file)

;; Local settings
(let ((fname "~/.emacs.local"))
  (when (file-exists-p fname)
    (load fname)))

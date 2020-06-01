(require 'cc-mode)
(require 'package)

(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

(defun set-terminal-mode ()
  (setq-default mode-line-format nil)
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (toggle-scroll-bar -1))

(unless (display-graphic-p) (set-terminal-mode))

(defun toggle-welcome-screen (value)
  (let ((notval (not value)))
    (setq inhibit-startup-screen notval)
    (setq inhibit-startup-message notval)
    (setq inhibit-splash-screen notval)))

(toggle-welcome-screen nil)

(defun initialize-melpa ()
  (let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                      (not (gnutls-available-p))))
	 (proto (if no-ssl "http" "https")))
    (when no-ssl (warn "\ Your version of Emacs does not support SSL connections."))
    (add-to-list 'package-archives (cons "melpa" (concat
						  proto "://melpa.org/packages/")) t)
    (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
    (when (< emacs-major-version 24)
      ;; For important compatibility libraries like cl-lib
      (add-to-list 'package-archives (cons "gnu" (concat
						  proto "://elpa.gnu.org/packages/")))))
  (package-initialize)
  )

(initialize-melpa)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(custom-enabled-themes (quote (AmberConsole)))
 '(custom-safe-themes
   (quote
    ("50706e2757d1c876672b9f22ad639f61b2d7d050bcd3c1b2b07e460611da2fc8" "eebea024af0b59bfa1b9068f337d3461f22d3cbbf2228d5ad2412edf0ae6b432" "a627b8fac6a8c02903c0865c40f6830f619e3b49f119ca95753036227aaf1587" "87570cba94c93fbab6b7e38c52252f3ec153d1d8c087b349d4793b313524ce50" default)))
 '(fill-column 80)
 '(package-selected-packages
   (quote
    (format-all typit olivetti clang-format+ clang-format auto-complete speed-type slime))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "PT Mono" :foundry "PARA" :slant normal :weight normal :height 98 :width normal)))))

(setq inferior-lisp-program "/usr/bin/sbcl")


(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
         (column (c-langelem-2nd-pos c-syntactic-element))
         (offset (- (1+ column) anchor))
         (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(defun mycmodehook ()
  ;; Add kernel style
  (c-add-style
   "linux-tabs-only"
   '("linux" (c-offsets-alist
	      (arglist-cont-nonempty
	       c-lineup-gcc-asm-reg
	       c-lineup-arglist-tabs-only)))))

(add-hook 'c-mode-common-hook 'mycmodehook)
(add-hook 'c++-mode-common-hook 'mycmodehook)

(defun enable-kernel-edit-mode ()
  (let ((filename (buffer-file-name)))
    ;; Enable kernel mode for the appropriate files
    (setq indent-tabs-mode t)
    (setq show-trailing-whitespace nil)
    (c-set-style "linux-tabs-only")))

(defun enable-c++-edit-mode ()
  (let ((filename (buffer-file-name)))
    ;; Enable kernel mode for the appropriate files
    (setq indent-tabs-mode t)
    (setq show-trailing-whitespace nil)
    (c-set-style "bsd")))



(add-hook 'c-mode-hook #'enable-kernel-edit-mode)
(add-hook 'c++-mode-hook #'enable-c++-edit-mode)

(defun my-save-hook ()
  "Called when files are saved."
  (delete-trailing-whitespace)
  )

(add-hook 'before-save-hook 'my-save-hook)

(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (buffer-file-name) (file-exists-p (buffer-file-name)) (not (buffer-modified-p)))
	(revert-buffer t t t))
      )
    )
  )

(global-set-key (kbd "<f5>") #'revert-all-buffers)
(global-set-key (kbd "<f6>") (lambda ()
			       (interactive)
			       (indent-region (point-min) (point-max))
			       (delete-trailing-whitespace)
			       ))

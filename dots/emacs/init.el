;; lstbit emacs config

;; elpaca prelude
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  (elpaca-use-package-mode))

(elpaca-wait) ;; block until elpaca is installed so we can use use-package below

(setq use-package-always-ensure t ;; forces use package to install packages if missing
      use-package-always-defer t) ;; forces use package to lazy load all packages unless demand t is specified


;; VIM CONFIGURATION
(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-want-keybinding nil
	evil-want-C-u-scroll t)
  :hook
  (elpaca-after-init . evil-mode)
  ;; I'm running into a bug with evil and the below is a workaround
  ;; https://github.com/emacs-evil/evil/issues/301#issuecomment-591570732
  (window-configuration-change . evil-normalize-keymaps)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :demand t
  :config
  (evil-collection-init '(dired magit corfu info help ediff grep compile man elfeed finder)))

;; BASE CONFIGURATION
(use-package emacs
  :ensure nil
  :init
  (setopt use-short-answers t)
  ;; setup custom file configuration
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (when (file-exists-p custom-file)
    (load-file custom-file))

  ;; backup file and autosave configuration
  (setq bit/user-data-dir (expand-file-name "~/.local/share/emacs/")
	bit/backup-dir (expand-file-name "~/.local/share/emacs/backups/")
	bit/autosave-dir (expand-file-name "~/.local/share/emacs/autosaves/"))

  (if (not (file-directory-p bit/user-data-dir))
      (make-directory bit/user-data-dir))

  (if (not (file-directory-p bit/backup-dir))
      (make-directory bit/backup-dir))

  (if (not (file-directory-p bit/autosave-dir))
      (make-directory bit/autosave-dir))

  ;; hardcoded paths as relative paths are required
  (setq auto-save-file-name-transforms '((".*" "~/.local/share/emacs/autosaves/" t))
	backup-directory-alist '(("." . "~/.local/share/emacs/backups/")))
  :config
  ;; clean up ui elements and turn off bell
  (setq ring-bell-function #'ignore)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (menu-bar-mode -1)
  (setq inhibit-splash-screen t)

  ;; enable displaying the time in the mode line
  (display-time-mode 1)

  ;; Append to undecorated to default-frame-alist
  (add-to-list 'default-frame-alist '(undecorated . t) t)

  ;; disable warning buffer pop us when using native-comp
  (setq native-comp-async-report-warnings-errors nil)

  ;; Enable Which Key
  (which-key-mode)

  ;; MACOS SPECIFIC CONFIG
  (when (eq system-type 'darwin)
    (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
    (add-to-list 'default-frame-alist '(ns-appearance . dark)))


  ;; FONT CONFIG
  (set-face-attribute 'default nil :font "Berkeley Mono" :height 110 :weight 'regular)
  (set-face-attribute 'variable-pitch nil :font "Berkeley Mono" :height 110 :weight 'regular)

  ;;; font toggle function
  (defvar bit/is-docked nil
    "Non-nil if we are using laptop only")

  (defvar bit/font-size-docked 140
    "The Font Size to be used when docked")

  (defvar bit/font-size-undocked 110
    "The Font Size to be used when undocked")

  (defun bit/toggle-font-size ()
    "Toggle between two hard coded font sizes"
    (let ((font-size (if bit/is-docked
			 bit/font-size-docked
		       bit/font-size-undocked)))
      (progn
	(set-face-attribute 'default nil :height font-size)
	(set-face-attribute 'variable-pitch nil :height font-size)
        (set-face-attribute 'org-table nil :height font-size))))

  (defun bit/toggle-docked ()
    "Toggle docked mode"
    (interactive)
    (setq bit/is-docked (not bit/is-docked))
    (message "DOCKED STATE: %s" (if bit/is-docked "ON" "OFF"))
    (bit/toggle-font-size))

  ;; BACKUP CONFIG
  (setq backup-by-copying t
	version-control t
	delete-old-versions t
	kept-new-versions 6
	kept-old-versions 2)

  ;; TEXT MODE CONFIGURATION
  (setq sentence-end-double-space nil
	require-final-newline t
	show-trailing-whitespace t
	;; better scrolling configuration
	pixel-scroll-precision-mode t)

  ;; Compile mode config
  (with-eval-after-load 'compile
    (setq compilation-scroll-output t))

  ;; Configure project root markers for box repo
  (setq project-vc-extra-root-markers '(".project")))

(use-package org
  :ensure nil
  :config
  (set-face-attribute 'org-table nil :font "Berkeley Mono" :height 110))

;; used for fixing path when loading under mac os
(use-package exec-path-from-shell
  :demand t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; vterm config
(use-package vterm)

;; misc helper functions

(defun bit/get-active-aws-profile ()
  "Print AWS_PROFILE if set."
  (interactive)
  (let ((env-var (getenv "AWS_PROFILE")))
    (if env-var
	(message (format "AWS_PROFILE: %s" env-var))
      (message "AWS_PROFILE has not been set"))))

(defun bit/get-known-aws-profiles ()
  "Look in ~/.aws/config for configured profile names."
  (let ((input
	 (shell-command-to-string "cat ~/.aws/config | grep -i profile | cut -d ' ' -f 2 | tr -d ']'")))
    (split-string input "\n" t)))

(defun bit/set-aws-profile ()
  "Set env_var for AWS_PROFILE based on a value chosen.
If prefix arg is set, it will unset the env var."
  (interactive)
  (if current-prefix-arg
      ;; setenv will unset if current-prefix-arg is t
      ;; since the prefix is set on the caller, the callee
      ;; will have it set too.
      (progn (setenv "AWS_PROFILE")
	     (message "AWS_PROFILE has been unset"))
    (setenv "AWS_PROFILE" (completing-read "AWS_PROFILE: " (bit/get-known-aws-profiles)))))

;; KEY BIND CONFIGURATION
(use-package general
  :demand t
  :config
  (general-evil-setup)

  ;; flymake keybinds
  (general-define-key
   :keymaps 'flymake-mode-map
   "M-n" 'flymake-goto-next-error
   "M-p" 'flymake-goto-prev-error)

  (general-create-definer bit-leader
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  (bit-leader
    "SPC" '("M-x" . execute-extended-command)
    "u"   '("C-u" . universal-argument)
    "'"   '("Open Terminal Here" . vterm)

    ;; Window Management
    "w"   '(:ignore t :which-key "window")
    "w h" 'evil-window-left
    "w j" 'evil-window-down
    "w k" 'evil-window-up
    "w l" 'evil-window-right
    "w s" 'split-window-vertically
    "w v" 'split-window-horizontally
    "w d" 'delete-window
    "w D" 'delete-other-windows

    ;; Buffer Management
    "b"   '(:ignore t :which-key "buffer")
    "b k" 'kill-current-buffer
    "b K" 'kill-buffer
    "b b" 'switch-to-buffer
    "b B" 'switch-to-buffer-other-window
    "b f" 'apheleia-format-buffer

    ;; File Management
    "f"   '(:ignore t :which-key "file")
    "f f" 'find-file
    "f F" 'find-file-other-window

    ;; Env Managment
    "e" '(:ignore t :which-key "env")
    "e a" '(:ignore t :which-key "aws")
    "e a g" 'bit/get-active-aws-profile
    "e a s" 'bit/set-aws-profile

    ;; Run Command
    "r"   '(:ignore t :which-key "run")
    "r c" 'shell-command
    "r a" 'async-shell-command
    "r r" 'shell-command-on-region
    "r g" 'rgrep

    ;; Code Commands
    "c" '(:ignore t :which-key "code")
    "c c" 'compile
    "c r" 'recompile
    "c a" 'eglot-code-actions

    ;; Open Apps?
    "o" '(:ignore t :which-key "open")
    "o r" 'elfeed

    ;; Help
    "h"   '(:ignote t :which-key "help")
    "h a" 'apropos-command
    "h f" 'describe-function
    "h k" 'describe-key
    "h v" 'describe-variable

    ;; Toggles (Flags)
    "t" '(:ignore t :which-key "toggles")
    "t d" '("toggle docked mode" . bit/toggle-docked)))

;; Workaround for Transient dependency issue with magit v4 (09082024)
(use-package transient
  :ensure (:host github :repo "magit/transient"))

;; GIT CONFIGURATION
(use-package magit
  :ensure (:host github :repo "magit/magit" :tag "v4.3.8")
  :init
  (bit-leader
    "g" '(:ignore t :which-key "git")
    "g g" '("Magit Status" . magit-status-here)))

;; PROG MODE CONFIGURATION
(use-package emacs
  :ensure nil
  :hook ((prog-mode . display-line-numbers-mode)
	 (conf-mode . display-line-numbers-mode)
	 (prog-mode . flymake-mode)
	 (conf-mode . flymake-mode))

  ;; configure treesitter modes
  :mode (("\\.ts\\'" . typescript-ts-mode)
	 ("\\.cjs\\'" . typescript-ts-mode)
	 ("\\.json\\'" . json-ts-mode)
	 ("\\.rs\\'" . rust-ts-mode)
	 ("\\.exs\\'" . elixir-ts-mode)
	 ("\\.elixir\\'" . elixir-ts-mode)
	 ("\\.ex\\'" . elixir-ts-mode)
	 ("mix\\.lock" . elixir-ts-mode))

  :config
  (setq display-line-numbers-type 'relative)

  ;; treesitter grammar installation
  (setq treesit-language-source-alist
	'((python . ("https://github.com/tree-sitter/tree-sitter-python.git"))
	  (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript.git" "master" "typescript/src"))
	  (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript.git" "master" "tsx/src"))
	  (hcl . ("https://github.com/tree-sitter-grammars/tree-sitter-hcl.git"))
	  (go . ("https://github.com/tree-sitter/tree-sitter-go.git"))
	  (janet-simple . ("https://github.com/sogaiu/tree-sitter-janet-simple.git"))
	  (bash . ("https://github.com/tree-sitter/tree-sitter-bash.git"))
	  (json . ("https://github.com/tree-sitter/tree-sitter-json.git"))
	  (rust . ("https://github.com/tree-sitter/tree-sitter-rust.git"))
	  (elixir . ("https://github.com/elixir-lang/tree-sitter-elixir"))
	  (heex . ("https://github.com/phoenixframework/tree-sitter-heex")))))

;; Janet configuration
(use-package janet-ts-mode
  :ensure (:host github
		 :repo "sogaiu/janet-ts-mode"
		 :files ("*.el")))

;; -- REPL Configuration
(use-package ajrepl
  :ensure (:host github
		 :repo "sogaiu/ajrepl"
		 :files ("*.el" "ajrepl"))
  :config
  (add-hook 'janet-ts-mode-hook #'ajrepl-interaction-mode))

;; terraform configuration
(use-package terraform-mode
  :custom
  (terraform-indent-level 4)
  :config
  (defun bit/terraform-init ()
    "initialise terraform for the current buffer"
    (interactive)
    (compile "terraform init -no-color"))

  (defun bit/terraform-validate ()
    "validate current directory"
    (interactive)
    (compile "terraform validate -no-color"))

  (defun bit/terraform-plan ()
    "plan current directory"
    (interactive)
    (compile "terraform plan -no-color"))

  (bit-leader
    :keymaps 'terraform-mode-map
    "c v" 'bit/terraform-validate
    "c i" 'bit/terraform-init
    "c c" 'bit/terraform-plan
    "c d" '(:ignore t :which-key "doc")
    "c d o" 'terraform-open-doc
    "c d y" 'terraform-kill-doc-url
    "c d r" 'terraform-insert-doc-in-comment))



(use-package eglot
  :ensure nil
  :init
  ;; Configure eglot for program major modes
  (add-hook 'python-ts-mode-hook 'eglot-ensure)
  (add-hook 'typescript-ts-mode-hook 'eglot-ensure)
  (add-hook 'terraform-mode-hook 'eglot-ensure)
  (add-hook 'bash-ts-mode-hook 'eglot-ensure)
  (add-hook 'qml-ts-mode-hook 'eglot-ensure)
  ;; Helper function to install all configured grammars.
  (defun bit/install-treesit-grammars ()
    "Install all grammars configured via treesit-language-source-alist.
This needs to be invoked after the alist is updated"
    (interactive)
    (dolist (pair treesit-language-source-alist)
      (let ((key (car pair))
	    (val (cdr pair)))
	(treesit-install-language-grammar key))))

  ;; configure remappable treesitter modes
  (add-to-list 'major-mode-remap-alist
	       '(python-mode . python-ts-mode)
	       '(shell-script-mode . bash-ts-mode))

  ;; Tell eglot to not mess with indent-tabs-mode
  :config
  (append eglot-stay-out-of indent-tabs-mode)
  (add-to-list 'eglot-server-programs
	       '(qml-ts-mode "qmlls6")))

;; Rust Setup
(use-package rustic)

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package yaml-mode
  :mode (("\\.yaml\\'" . yaml-mode)
	 ("\\.yml\\'" . yaml-mode)))

;; auto-complete config
(use-package vertico
  :init
  (vertico-mode))

(use-package marginalia
  :init
  (marginalia-mode)

  :custom
  (marginalia-alight 'right))

(use-package corfu
  :after evil
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode) ;; used for documentaiton popup when auto-completing

  :custom
  (corfu-cycle t)

  :config
  (general-def 'insert corfu-map
    ;; <UP> and <DOWN> work in the popup buffer when it's selected too.
    "C-n" 'corfu-next
    "C-p" 'corfu-previous
    "C-h" 'corfu-popupinfo-mode
    "C-<return>" 'corfu-complete))

;; Formatter Configuration
(use-package apheleia
  :init
  (apheleia-global-mode +1)
  :config
  ;; typescript config
  (setf (alist-get 'prettier-typescript apheleia-formatters)
	'("apheleia-npx" "prettier" "--stdin-filepath" filepath))
  (setf (alist-get 'prettier-json apheleia-formatters)
	'("apheleia-npx" "prettier" "--stdin-filepath" filepath)))

;; direnv
(use-package direnv
  :config
  (direnv-mode))

;; elisp config
(use-package emacs
  :ensure nil
  :hook
  (emacs-lisp-mode . display-line-numbers-mode)
  (emacs-lisp-mode . flymake-mode)
  (emacs-lisp-mode . electric-pair-mode))

;; below is untested
;; (use-package emacs
;;   :ensure nil
;;   :hook (markdown-mode . (lambda () (setq indent-tabs-mode nil))))

;; Common Lisp setup
(use-package slime
  :config
  (setq inferior-lisp-program "sbcl")
  (slime-setup '(slime-quicklisp
		 slime-asdf
		 slime-mrepl)))

;; QML Setup for QT QML
(use-package qml-ts-mode
  :ensure (:host github
		 :repo "xhcoding/qml-ts-mode"
		 :files ("*.el")))

;; nix setup
(use-package nix-mode
  :mode "\\.nix\\'")

;; elfeed configuration
(use-package elfeed
  :config
  (setq elfeed-feeds
	'(("https://xeiaso.net/blog.rss" tech)
	  ("https://trickster.dev/post/index.xml" tech)
	  ("https://drewdevault.com/blog/index.xml" tech)
	  ("https://protesilaos.com/commentary.xml" life philosophy)
	  ("https://protesilaos.com/interpretations.xml" life philosophy)
	  ("https://protesilaos.com/poems.xml" life poetry)
	  ("https://www.seangoedecke.com/rss.xml" tech)
	  ("https://xn--gckvb8fzb.com/index.xml" tech)
	  ("https://ntietz.com/atom.xml" tech)
	  ("https://jyn.dev/atom.xml" tech)
	  ("https://www.scattered-thoughts.net/atom.xml" tech))))

;; theme installation
(use-package solarized-theme
  :demand t
  :config
  (load-theme 'solarized-light))

;; verb for making http requests from org
(use-package verb
  :ensure t)

(use-package kdl-mode
  :ensure t
  :mode "\\.kdl\\'")

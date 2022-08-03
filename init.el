;; ==================== General Config

(setq inhibit-startup-message t
      visible-bell t)

(hl-line-mode 1)                     ; Highlight current line
(blink-cursor-mode -1)               ; Solid cursor
(tool-bar-mode -1)                   ; Hide toolbar
(scroll-bar-mode -1)                 ; Hide scrollbar
(menu-bar-mode -1)                   ; Hide menu bar

;; Display line numbers
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook
		shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Store old commands
(setq history-length 25)
(savehist-mode 1)

;; Come back to where I left off.
(save-place-mode 1)

;; Keep random variables out of my config
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror' 'nomessage)

;; Auto-update files
(global-auto-revert-mode 1)

;; Start maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ; Let me escape
;; ==========================  Package Manager

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; ================== Packages

(defun isard/evil-hook ()
  (dolist (mode '(custom-mode
		  eshell-mode
		  git-rebase-mode
		  erc-mode
		  circle-server-mode
		  circle-chat-mode
		  circle-query-mode
		  sauron-mode
		  term-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :init
  (setq evil-want-integration t
	evil-want-keybinding nil
	evil-want-C-u-scroll t
	evil-want-C-i-jump nil)
  (evil-mode 1)
  :hook (evil-mode . isard/evil-hook)
  :config
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil magit
  :config (evil-collection-init))

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale-text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer isard/leader-keys
			  :keymaps '(normal insert visual emacs)
			  :prefix "SPC"
			  :global-prefix "C-SPC"))

(isard/leader-keys
 "t" '(:ignore t :which-key "toggles")
 "ts" '(hydra-text-scale/body :which-key "scale"))



(use-package command-log-mode)

;; Ivy completion Todo: look at helm

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil))

(global-key-binding (kbd "C-M-j") 'counsel-switch-buffer)
(global-key-binding (kbd "C-M-k") 'counsel-switch-buffer)

(use-package all-the-icons
  :if (display-graphic-p)
  :commands all-the-icons-install-fonts
  :init
  (unless (find-font (font-spec :name "all-the-icons"))
    (all-the-icons-install-fonts t)))

(use-package all-the-icons-dired
  :if (display-graphic-p)
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 40)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish
  :config
  (setq which-key-idle-delay 0.3))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package projectile
  :diminish projectile-mode
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :custom ((projectile-completion-system 'ivy))
  :init
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-swotch-project-action #'projectile-dired)
  (projectile-mode 1))

(use-package counsel-projectile
  :init (counsel-projectile-mode))

(use-package ripgrep)

(use-package rg)

(use-package magit)
;;:custom
;;(magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

; =================== Theme

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-vibrant t)

  (doom-themes-visual-bell-config)

;;(doom-themes-neotree-config)

;;(setq doom-themes-treemacs-theme "doom-colors")
;;(doom-themes-treemacs-config)
  
  (doom-themes-org-config))

;; Font

(set-face-attribute 'default nil :font "UbuntuMono NF" :height 150)

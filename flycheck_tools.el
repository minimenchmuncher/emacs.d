

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Ezra's emacs startup
;;; based on the work of many others, including github.com/belything/dotemacs
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; snippets
(require 'yasnippet)
(yas-global-mode 1)

;; tabs
(require 'tabbar)
(tabbar-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ido
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t)
(setq ido-create-new-buffer 'always)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; company
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(add-hook 'after-init-hook 'global-company-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ESS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'ess-site)

;; turn off command echoing
(setq ess-eval-visibly-p nil)

;; R help
(setq inferior-ess-r-help-command "help(\"%s\", help_type=\"html\")\n")

;; enable function arg hint
(require 'ess-eldoc)

;; start tracebug
(require 'ess-tracebug)
(add-hook 'ess-post-run-hook 'ess-tracebug t)

;; Code folding in ess mode
(add-hook 'ess-mode-hook
          (lambda()
            (local-set-key (kbd "C-c <right>") 'hs-show-block)
            (local-set-key (kbd "C-c <left>")  'hs-hide-block)
            (local-set-key (kbd "C-c <up>")    'hs-hide-all)
            (local-set-key (kbd "C-c <down>")  'hs-show-all)
            (hs-minor-mode t)))
(autoload 'ess-rdired "ess-rdired"
    "View *R* objects in a dired-like buffer." t)

;; activate parethesis matching for
(show-paren-mode t)


(setq display-buffer-alist
      '(("*R Dired"
         (display-buffer-reuse-window display-buffer-in-side-window)
         (side . left)
         (slot . -1)
         (window-width . 0.25)
         (reusable-frames . nil))
        ("*R"
         (display-buffer-reuse-window display-buffer-at-bottom)
         (window-width . 0.5)
         (reusable-frames . nil))
        ("*Help"
         (display-buffer-reuse-window display-buffer-in-side-window)
         (side . left)
         (slot . 1)
         (window-width . 0.25)
         (reusable-frames . nill))))

;;(require 'ess-site) ;; don't load ALL of ess, just r
;;(require 'ess-r-mode)
;;(ess-toggle-underscore nil)  ;; disable underscore mode

(use-package auto-complete
  :ensure t
  :init
  (progn
    (ac-config-default)
    (global-auto-complete-mode t)
    ))

(require 'auto-complete-config)
(add-to-list 'load-path "~/.emacs.d/autocomplete/")
(add-to-list 'ac-dictionary-directories "~/.emacs.d/autocomplete/ac-dict")
(define-key ac-completing-map [tab] 'ac-complete)

;;(setq ac-auto-start nil)
;;(define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
;;(define-key ac-completing-map [return] nil)
;;(setq ac-quick-help-delay 0.1)

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))
(add-hook 'c++-mode-hook
          (lambda () (setq flycheck-gcc-include-path
                           (list "C:/Program Files/R/R-4.0.3/include"
                                 "C:/Users/EzraTucker/R/win-library/4.0/Rcpp/include"))))

;; C/C++ compile
(use-package modern-cpp-font-lock
:ensure t)

(defun code-compile ()
  (interactive)
  (unless (file-exists-p "Makefile")
    (set (make-local-variable 'compile-command)
     (let ((file (file-name-nondirectory buffer-file-name)))
       (format "%s -o %s %s"
           (if  (equal (file-name-extension file) "cpp") "g++" "gcc" )
           (file-name-sans-extension file)
           file)))
    (compile compile-command)))

(global-set-key [f9] 'code-compile)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; buffer move
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'buffer-move)
(global-set-key (kbd "<C-S-up>")    'buf-move-up)
(global-set-key (kbd "<C-S-down>")  'buf-move-down)
(global-set-key (kbd "<C-S-left>")  'buf-move-left)
(global-set-key (kbd "<C-S-right>") 'buf-move-right)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; magit (for git)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package magit
  :ensure t
  :init
  (progn
    (bind-key "C-x g" 'magit-status)))
(global-set-key (kbd "C-x M-g") 'magit-dispatch)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; dired and direx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(define-key dired-mode-map "i" 'dired-subtree-insert)
;;(define-key dired-mode-map ";" 'dired-subtree-remove)

(require 'popwin)
(popwin-mode 1)

(require 'direx)
(push '(direx:direx-mode :position left :width 25 :dedicated t)
      popwin:special-display-config)
(global-set-key (kbd "C-x C-j") 'direx:jump-to-directory-other-window)
;;(global-set-key (kbd "C-x C-j") 'direx:jump-to-directory)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Markdown preview etc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Requires:
;;   - impatient-mode
;;   - M-x httpd-start
;;   - M-x impatient-mode
;;   - M-x imp-set-user-filter RET markdown-html RET

(defun markdown-html (buffer)
  (princ (with-current-buffer buffer
    (format "<!DOCTYPE html><html><title>Impatient Markdown</title><xmp theme=\"united\" style=\"display:none;\"> %s  </xmp><script src=\"http://strapdownjs.com/v/0.2/strapdown.js\"></script></html>" (buffer-substring-no-properties (point-min) (point-max))))
  (current-buffer)))

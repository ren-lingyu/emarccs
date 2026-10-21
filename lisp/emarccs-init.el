;;; emarccs-init.el --- Define regular configuration initialization -*- lexical-binding: t; -*-

;;; Commentary:

;; Define the configuration initializer without loading functional modules.
;; A successful initialization, including custom.el, runs only once.

;;; Code:

(defvar use-package-always-ensure)

(defvar emarccs--initialized nil
  "Non-nil after regular Emarccs initialization has completed.")

(defvar emarccs--initializing nil
  "Non-nil while regular Emarccs initialization is running.")

(defun emarccs-initialize ()
  "Initialize the Emarccs configuration once.
Ignore recursive calls during initialization.  Mark initialization complete
only after all modules and optional user customizations load successfully."
  (unless (or emarccs--initialized emarccs--initializing)
    (let ((emarccs--initializing t))
      (require 'use-package)
      (setq use-package-always-ensure nil)

      ;; main
      (require 'emarccs-basic) ; 基本设置

      (require 'emarccs-help) ; 帮助信息优化

      (require 'emarccs-theme) ; 主题

      (require 'emarccs-org) ; Org 设置

      (require 'emarccs-tex) ; Tex 设置

      (require 'emarccs-complete) ; 自动补全

      (require 'emarccs-lisp)

      (require 'emarccs-org-roam) ; org-roam 及相关设置

      (require 'emarccs-org-roam-organize) ; org-roam organize、citar 及相关设置

      (require 'emarccs-org-latex-preview) ; 预览

      (require 'emarccs-feed)

      (require 'emarccs-org-roam-blog) ; 博客发布设置

      ;; debug
      (require 'emarccs-debug)

      ;; customize
      (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
      (when (file-exists-p custom-file)
        (load-file custom-file))
      (setq emarccs--initialized t))))

(provide 'emarccs-init)

;;; emarccs-init.el ends here

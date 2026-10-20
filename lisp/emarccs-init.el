;;; emarccs-init.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

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

;; end
(provide 'emarccs-init)

;;; emarccs-init.el ends here

;;; init.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

;; 版本和操作系统检查
(let ((minver "28.1"))
  (when (version< emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version< emacs-version "30.1")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

;; (defconst *is-a-mac* (eq system-type 'darwin)) ; 判断是否处于MacOS

;; 设定源码加载路径
(add-to-list 'load-path (expand-file-name "lisp/share" user-emacs-directory))

;; customize
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
 (load-file custom-file))

;; main settings
(require 'emarccs-basic) ; 基本设置

(require 'emarccs-help) ; 帮助信息优化

(require 'emarccs-theme) ; 主题

(require 'emarccs-org) ; Org设置

(require 'emarccs-tex) ; Tex设置

(require 'emarccs-complete) ; 自动补全

(require 'emarccs-org-roam) ; org-roam及相关设置

(require 'emarccs-org-roam-citar) ; org-roam中citar及相关设置

(require 'emarccs-org-latex-preview) ; 预览

(require 'emarccs-feed)

(require 'emarccs-ai) ; AI辅助

(require 'emarccs-blog-publish) ; 博客发布设置

(require 'emarccs-orgraph) ; orgraph

;; debug
(require 'emarccs-debug)

;; End
(provide 'init)
;;; init.el ends here

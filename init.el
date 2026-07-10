;;; init.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

;; 版本检查
(let* ((minver "30.2"))
  (when (version< emacs-version minver)
    (display-warning
     'emarccs
     (format "This configuration is only tested with Emacs %s or newer; current Emacs is %s."
             minver emacs-version)
     :warning)))

;; 设定源码加载路径
(add-to-list 'load-path (expand-file-name "lisp/share" user-emacs-directory))

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

;; customize
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
 (load-file custom-file))

;; End
(provide 'init)
;;; init.el ends here

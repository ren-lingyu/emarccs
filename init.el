;;; init.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

;; version check
(let ((minver "31.0"))
  (when (version< emacs-version minver)
    (display-warning
     'emarccs
     (format "This configuration is only tested with Emacs %s or newer; current Emacs is %s."
             minver emacs-version)
     :warning)))

;; load-path
(add-to-list 'load-path
             (expand-file-name "lisp/share"
                               (file-name-directory (or load-file-name
                                                        buffer-file-name))))

;; main settings
(require 'emarccs-shared-basic) ; 基本设置

(require 'emarccs-shared-help) ; 帮助信息优化

(require 'emarccs-shared-theme) ; 主题

(require 'emarccs-shared-org) ; Org 设置

(require 'emarccs-shared-tex) ; Tex 设置

(require 'emarccs-shared-complete) ; 自动补全

(require 'emarccs-shared-org-roam) ; org-roam 及相关设置

(require 'emarccs-shared-org-roam-citar) ; org-roam 中 citar 及相关设置

(require 'emarccs-shared-org-latex-preview) ; 预览

(require 'emarccs-shared-feed)

(require 'emarccs-shared-ai) ; AI 辅助

(require 'emarccs-shared-blog-publish) ; 博客发布设置

(require 'emarccs-shared-orgraph) ; orgraph

;; debug
(require 'emarccs-shared-debug)

;; customize
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
 (load-file custom-file))

;; end
(provide 'init)

;;; init.el ends here

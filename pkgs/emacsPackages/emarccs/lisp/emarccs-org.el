;;; emarccs-org.el --- Org mode configuration -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(eval-when-compile
  (require 'use-package))

(use-package org
  ;; :defer
  :demand t
  :init (setq org-directory (expand-file-name "~/org/"))
  :config
  (setq org-startup-indented t)
  (setq org-startup-truncated nil)
  (setq org-startup-folded nil)
  (setq org-hide-leading-stars nil)
  (setq org-latex-default-packages-alist nil) ; 确保默认包列表为空
  (setq org-latex-packages-alist nil) ; 确保包列表为空
  (setq org-cite-export-processors
        '((latex biblatex) (html csl) (t basic)))
  (setq org-src-fontify-natively t) ; Org代码块语法高亮
  (setq org-src-tab-acts-natively t) ; Org代码块TAB缩进
  (setq org-timestamp-formats
        '("%Y-%m-%d %a %z" . "%Y-%m-%d %H:%M:%S %z"))
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq bookmark-default-file
        (expand-file-name "./cache/bookmarks" org-directory))
  (setq org-publish-timestamp-directory
        (expand-file-name "./cache/.org-timestamps/" org-directory))
  (setq org-id-locations-file
        (expand-file-name "./cache/.org-id-locations" org-directory))
  (set-face-attribute 'org-footnote nil
                      :underline nil ; 移除下划线
                      :foreground "#79a8ff" ; 保留颜色但不设置其他属性
                      :background 'unspecified
                      :inherit nil
                      :inverse-video 'unspecified
                      :weight 'unspecified)
  (set-face-attribute 'org-link nil
                      :underline t
                      :foreground "#6b6b6b"
                      :background "#ffffff"
                      :weight 'ultra-bold
                      :inverse-video t))

(use-package emarccs--org-extension-block
  :after org
  :config
  (setq emarccs--org-extension-block-preserve-namespace t)
  (setq emarccs--org-extension-block-registry
        '(("reply" . (:from :subject :date))
          ("theorem" . (:title))
          ("lemma" . (:title))
          ("proposition" . (:title))
          ("corollary" . (:title))
          ("definition" . (:title))
          ("example" . (:title))
          ("remark" . (:title))
          ("claim" . (:title))
          ("hint" . (:title))
          ("exercise" . (:title :number))
          ("exercise*" . (:title))
          ("proof" . ())
          ("solution" . ()))))

;; 嵌入
(use-package org-transclusion
  :after org
  :hook (org-mode . org-transclusion-mode))

(use-package org-include-inline
  :disabled
  :after org
  :hook (org-mode . org-include-inline-mode))

;; GTD and agenda
(use-package org-edna
  :after org
  :config
  (org-edna-mode 1)
  (setq org-edna-use-inheritance t))

(use-package org-gtd
  :no-require t
  :defines org-gtd-clarify-mode-map
  :after (org org-edna)
  :init
  (setq org-gtd-update-ack "4.0.0")
  (setq org-gtd-directory (expand-file-name "agenda/" org-directory))
  (unless (file-directory-p org-gtd-directory)
    (make-directory org-gtd-directory t))
  :custom
  (org-todo-keywords
   '((sequence "TODO" "NEXT" "WAIT" "|" "DONE" "CNCL")))
  (org-gtd-keyword-mapping
   '((todo . "TODO")
     (next . "NEXT")
     (wait . "WAIT")
     (done . "DONE")
     (canceled . "CNCL")))
  :config (setq org-agenda-files (list org-gtd-directory))
  :bind
  (("C-c d" . org-gtd-command-center)
   :map
   org-gtd-clarify-mode-map
   ("C-c c" . org-gtd-organize)
   :map
   org-agenda-mode-map
   ("C-c ." . org-gtd-agenda-transient)))

(provide 'emarccs-org)
;;; emarccs-org.el ends here.

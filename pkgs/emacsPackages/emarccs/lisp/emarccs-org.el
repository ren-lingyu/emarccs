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
  (setq org-todo-keywords
        '((sequence "TODO" "NEXT" "WAIT" "|" "DONE" "CNCL")))
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  ;; Keep the GTD directory explicit for clients that read the variable.
  (setq org-agenda-files
        (list org-directory (expand-file-name "gtd/" org-directory)))
  (require 'emarccs--org-agenda-files-advice)
  (advice-add 'org-agenda-files
              :around
              (emarccs--org-agenda-files-advice '("cache"))
              '((name . emarccs--org-agenda-files)))
  (setq bookmark-default-file
        (expand-file-name "./cache/bookmarks" org-directory))
  (setq org-publish-timestamp-directory
        (expand-file-name "./cache/.org-timestamps/" org-directory))
  (setq org-id-locations-file
        (expand-file-name "./cache/.org-id-locations" org-directory)))

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

(use-package org-texmacs
  :after org
  :init
  (setq org-texmacs-export-menu-keys
        '(:prefix ?T :buffer ?T :file ?t :pdf ?p))
  :custom
  ;; (org-texmacs-program "texmacs")
  (org-texmacs-worker-start-timeout 60)
  (org-texmacs-worker-request-timeout 10)
  (org-texmacs-format-headline-function
   #'org-texmacs-format-headline-default-function)
  (org-texmacs-cite-export-processor '(texmacs-native "plain" nil))
  (org-texmacs-typed-references t)
  (org-texmacs-document-style '("generic" "smart-ref" "emarccs-math"))
  (org-texmacs-document-initial
   '(("page-type" . "a4")
     ("page-width-margin" . "false")
     ("page-height-margin" . "false")
     ("page-odd" . "12.7mm")
     ("page-even" . "12.7mm")
     ("page-right" . "12.7mm")
     ("page-top" . "12.7mm")
     ("page-bot" . "12.7mm")))
  (org-texmacs-pdf-file-links-as-absolute nil)
  (org-texmacs-link-org-files-as-pdf t)
  (org-texmacs-edit-mode 'scheme-mode)
  (org-texmacs-fragment-tags
   '("math"
     "equation"
     "equation*"
     "eqnarray"
     "eqnarray*"
     "align"
     "align*"
     "gather"
     "gather*"
     "eqsplit"
     "eqsplit*"
     "reference"
     "rcl-table")))

;; 嵌入
(use-package org-transclusion
  :after org
  :hook (org-mode . org-transclusion-mode))

(use-package org-include-inline
  :disabled
  :after org
  :hook (org-mode . org-include-inline-mode))

(use-package org-agenda
  :after org
  :bind (("C-c a" . org-agenda))
  :custom
  (org-agenda-span 'week)
  (org-agenda-start-on-weekday 1)
  (org-agenda-skip-unavailable-files t)
  :config
  (add-to-list
   'org-agenda-custom-commands
   '("D" "Daily dashboard"
     ((agenda
       ""
       ((org-agenda-span 1)
        (org-agenda-start-day nil)
        (org-agenda-overriding-header "Today's schedule")))
      (todo
       "NEXT" ((org-agenda-overriding-header "Next actions")))))))

;; GTD
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
  (setq org-gtd-directory (expand-file-name "gtd/" org-directory))
  (unless (file-directory-p org-gtd-directory)
    (make-directory org-gtd-directory t))
  :custom
  (org-gtd-keyword-mapping
   '((todo . "TODO")
     (next . "NEXT")
     (wait . "WAIT")
     (done . "DONE")
     (canceled . "CNCL")))
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

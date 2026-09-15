;;; emarccs-shared-org-roam.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

;; org-roam
(use-package org-roam
  ;; :defer
  ;; :demand t
  :after (org)
  :custom
  (org-roam-directory (expand-file-name "./roam/" org-directory))   ;; 你的笔记根目录
  (org-roam-db-location (expand-file-name "./roam/.org-roam.db" org-directory)) ;; 数据库文件位置
  (org-roam-dailies-directory "journal/")
  (org-roam-completion-everywhere t)
  (org-roam-node-display-template "${title} ${tags}")
  (org-roam-db-update-method 'immediate)
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n l" . org-roam-buffer-toggle)
   ("C-c n c" . org-roam-capture)
   ("C-c c l" . emarccs-shared-org-roam-forward-links))
  :config
  (org-roam-db-autosync-mode)
  ;; (advice-add 'org-roam-mode-hook :after
  ;;   (lambda (&rest _)
  ;;     (display-line-numbers-mode 1)
  ;;     (font-lock-mode 1)
  ;;   )
  ;; )
  (setq org-roam-node-display-template
        (concat
         "${title:*} "
         (propertize "${tags:30}" 'face 'org-tag)))
  (setq org-roam-capture-templates
        (append org-roam-capture-templates `(("I" "post index" plain "%?"
                                              :if-new
                                              (file+head
                                               "permanent/${slug}.org"
                                               ,(concat
                                                 "#+TITLE: ${title}\n"
                                                 "#+INDEX: ${title}\n"
                                                 "#+DESCRIPTION:\n"
                                                 "#+AUTHOR: aRenCoco\n"
                                                 "#+EMAIL: aRen_Coco@outlook.com\n"
                                                 "#+DATE: " (format-time-string "<%Y-%m-%d %a %z>") "\n"
                                                 "#+FILETAGS: :zettel:blog:\n"
                                                 ))
                                              :unnarrowed t))))
  (defun emarccs-shared-org-roam-forward-links (&optional other-window)
    "Select an Org-roam node linked from the current buffer.

All `id' links recognized by `org-roam-db-map-links', including
links in elements configured by `org-roam-db-extra-links-elements',
are considered.

With prefix argument OTHER-WINDOW, visit the selected node in
another window."
    (interactive "P")
    (let (ids)
      (org-roam-db-map-links
       (list
        (lambda (link)
          (when (string= (org-element-property :type link) "id")
            (push (org-element-property :path link) ids)))))
      (setq ids (delete-dups ids))
      (unless ids
        (user-error "No Org-roam forward links found"))
      (org-roam-node-visit
       (org-roam-node-read
        nil
        (lambda (node)
          (member (org-roam-node-id node) ids))
        nil
        t
        "Forward link: ")
       other-window)))
  (defun emarccs-shared-org-roam-update-link-description ()
    "Update the description of the link at point to match the title of the corresponding Org-roam node in the database.
If the link is not an Org-roam ID link or the node cannot be found, display an appropriate message without making changes."
    (interactive)
    (let ((element (org-element-context)))
      ;; Check if the cursor is on a link element
      (if (eq (org-element-type element) 'link)
          (let* (;; Link type, e.g., "id"
                 (link-type (org-element-property :type element))
                 ;; Link target (ID for Org-roam)
                 (link-path (org-element-property :path element))
                 ;; Start of description text
                 (desc-begin (org-element-property :contents-begin element))
                 ;; End of description text
                 (desc-end (org-element-property :contents-end element)))
            ;; Ensure the link is an Org-roam ID link
            (if (and (string= link-type "id") link-path)
                (let* ((node-id link-path)
                       ;; Query Org-roam database for the node title using EmacSQL
                       (title (caar (org-roam-db-query
                                     [:select title :from nodes :where (= id $s1)]
                                     node-id))))
                  (cond
                   ;; Case 1: Node not found
                   ((null title)
                    (message "No node found with id=%s." node-id))
                   ;; Case 2: Description already matches the node title
                   ((and
                     desc-begin
                     desc-end
                     (string= title (buffer-substring-no-properties desc-begin desc-end)))
                    (message "The link description is already up-to-date."))
                   ;; Case 3: Update description to match node title
                   (t
                    (save-excursion
                      (goto-char desc-begin)
                      (delete-region desc-begin desc-end)
                      (insert title))
                    (message "Description updated to: %s" title))))
              ;; Not an ID link
              (message "The current link is not an Org-roam ID link.")))
        ;; Cursor is not on a link
        (message "The cursor is not on a link.")))))

(use-package org-roam-include
  :after org-roam
  :hook
  ((after-init . org-roam-include-mode)))

(global-set-key (kbd "C-c h d") (lambda () (interactive) (insert (concat "\n* " (format-time-string "%Y-%m-%d %A %z") "\n"))))

(use-package org-roam-ui
  :after org-roam
  ;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
  ;;         a hookable mode anymore, you're advised to pick something yourself
  ;;         if you don't care about startup time, use
  ;;  :hook (after-init . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; 卡片工作台
(use-package org-workbench
  :disabled
  :after org-roam ; 或 org-supertag、org-brain 等
  :config
  (org-workbench-setup))

;; DATE
(use-package org-roam-timestamps
  :after org-roam
  :config
  (org-roam-timestamps-mode 1)
  (setq org-roam-timestamps-parent-file t)
  (setq org-roam-timestamps-remember-timestamps t))

(provide 'emarccs-shared-org-roam)
;;; emarccs-shared-org-roam.el ends here

;;; emarccs-shared-org-roam.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

;; org-roam
(use-package org-roam
  :defer
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
   ("C-c n c" . org-roam-capture))
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
                                              :unnarrowed t)))))

(use-package org-roam-organize
  :after (org-roam citar-org-roam)
  :custom
  (org-roam-organize-directory org-roam-directory)
  (org-roam-organize-registry
   (list (list :name "navigation"
               :tag "map"
               :moc t
               :basic t
               :directory "navigation"
               :inbox "Not be Classified"
               :template '((keywords . ((author . "Lingyu Ren")
                                        (date . "<%<%Y-%m-%d %A %z>>")
                                        (description . nil)
                                        (filetags . ("map"))))))
         (list :name "fleeting"
               :tag "idea"
               :basic t
               :directory "fleeting"
               :inbox "Not be Classified"
               :template '((keywords . ((author . "Lingyu Ren")
                                        (date . "<%<%Y-%m-%d %A %H:%M:%S %z>>")
                                        (description . nil)
                                        (filetags . ("idea"))))))
         (list :name "literature"
               :tag "ref"
               :cite t
               :basic t
               :directory "literature"
               :inbox "Citing Nodes"
               :provider #'emarccs-shared-org-roam-organize-citar-provider
               :template '((properties . ((roam_refs . "@${citar-key}")))
                           (keywords . ((author . "${citar-author}")
                                        (year . "${citar-year}")
                                        (month . "${citar-month}")
                                        (doi . "${citar-doi}")
                                        (isbn . "${citar-isbn}")
                                        (url . "${citar-url}")
                                        (description . nil)
                                        (filetags . ("ref"))))))
         (list :name "permanent"
               :tag "zettel"
               :basic t
               :directory "permanent"
               :inbox "Not be Classified"
               :template '((keywords . ((author . "Lingyu Ren")
                                        (date . "<%<%Y-%m-%d %A %H:%M:%S %z>>")
                                        (description . nil)
                                        (filetags . ("zettel"))))))
         (list :name "note"
               :tag "note"
               :basic nil
               :directory "permanent"
               :inbox "Not be Classified"
               :template '((keywords . ((author . "Lingyu Ren")
                                        (date . "<%<%Y-%m-%d %A %H:%M:%S %z>>")
                                        (description . nil)
                                        (filetags . ("zettel" "note"))))))
         (list :name "blog"
               :tag "blog"
               :basic nil
               :directory "permanent"
               :inbox "Not be Classified"
               :template '((keywords . ((author . "aRenCoco")
                                        (date . "<%<%Y-%m-%d %a %z>>")
                                        (email . "aRen_Coco@outlook.com")
                                        (description . nil)
                                        (filetags . ("zettel" "blog"))))))))
  (org-roam-organize-moc-managed-tag-property "MOC_MANAGED_TAG")
  (org-roam-organize-moc-managed-node-count-property "MOC_MANAGED_NODE_COUNT")
  :config
  (with-eval-after-load 'citar-org-roam
    (defun emarccs-shared--org-roam-citing-node-by-key (key)
      "Return the first Org-roam node that has cite ref KEY, or nil."
      (when-let* ((row (car (org-roam-db-query (vector :select (vector 'n:id)
                                                       :from '(as refs r)
                                                       :inner :join '(as nodes n)
                                                       :on '(= r:node_id n:id)
                                                       :where '(and (= r:ref $s1)
                                                                    (= r:type "cite"))
                                                       :limit 1)
                                               key)))
                  (id (car row)))
        (org-roam-node-from-id id)))
    (defun emarccs-shared-org-roam-organize-citar-provider (_record)
      "Return an Org-roam Organize node creation request from a Citar entry."
      (let* ((key (citar-select-ref))
             (existing_node (emarccs-shared--org-roam-citing-node-by-key key)))
        (when key
          (if existing_node
              (progn
                (org-roam-node-visit existing_node)
                nil)
            (let* ((entry (citar-get-entry key))
                   (title (or (citar-format--entry "${title}" entry)
                              key)))
              (list :title title
                    :info (list :citar-key key
                                :citar-title title
                                :citar-author (citar-format--entry "${author editor}" entry)
                                :citar-year (citar-format--entry "${year issued date}" entry)
                                :citar-month (citar-format--entry "${month}" entry)
                                :citar-doi (citar-format--entry "${doi}" entry)
                                :citar-isbn (citar-format--entry "${isbn}" entry)
                                :citar-url (citar-format--entry "${url}" entry)))))))))
  :bind
  (("C-c o o" . org-roam-organize-mode)
   ("C-c o c" . org-roam-organize-check-setup)
   ("C-c o n c" . org-roam-organize-node-create)
   ("C-c o m m" . org-roam-organize-moc-open-index)
   ("C-c o m c" . org-roam-organize-moc-create)
   ("C-c o m s" . org-roam-organize-moc-sync)
   ("C-c o r c" . org-roam-organize-cite-sync))
  :hook
  ((after-init . org-roam-organize-mode)))

(use-package org-roam-include
  :after org-roam
  :hook
  ((after-init . org-roam-include-mode)))

(global-set-key (kbd "C-c h d") (lambda () (interactive) (insert (concat "\n* " (format-time-string "%Y-%m-%d %A %z") "\n"))))

(use-package consult-org-roam
  :after (org-roam consult)
  :init
  (require 'org-roam)
  (require 'consult)
  (require 'consult-org-roam)
  :custom
  ;; Use `ripgrep' for searching with `consult-org-roam-search'
  (consult-org-roam-grep-func #'consult-ripgrep)
  ;; Configure a custom narrow key for `consult-buffer'
  (consult-org-roam-buffer-narrow-key ?r)
  ;; Display org-roam buffers right after non-org-roam buffers
  ;; in consult-buffer (and not down at the bottom)
  (consult-org-roam-buffer-after-buffers nil)
  :config
  ;; Activate the minor mode
  (consult-org-roam-mode t)
  ;; Eventually suppress previewing for certain functions
  (consult-customize
   consult-org-roam-forward-links
   ;; :preview-key "TAB"
   ;; :preview-key 'any
   :preview-key "M-.")
  (defun emarccs-shared-consult-org-roam-forward-links (&optional other-window)
    "Select an Org-roam forward link contained in the current buffer.
If OTHER-WINDOW is non-nil, visit the node in another window."
    (interactive)
    (let (id-links)
      (org-roam-db-map-links
       (list
        (lambda (link)
          (when (string= (org-element-property :type link) "id")
            (push (org-element-property :path link)
                  id-links)))))
      (setq id-links (delete-dups id-links))
      (unless id-links
        (user-error "No forward links found"))
      (let ((chosen-node
             (consult-org-roam-node-read
              ""
              (lambda (node)
                (and (org-roam-node-p node)
                     (member (org-roam-node-id node)
                             id-links))))))
        (consult-org-roam--open-or-capture
         other-window
         chosen-node))))
  (advice-add #'consult-org-roam-forward-links
              :override
              #'emarccs-shared-consult-org-roam-forward-links)
  :bind
  ;; Define some convenient keybindings as an addition
  ("C-c c f" . consult-org-roam-file-find)
  ("C-c c b" . consult-org-roam-backlinks)
  ("C-c c B" . consult-org-roam-backlinks-recursive)
  ("C-c c l" . consult-org-roam-forward-links)
  ("C-c c s" . consult-org-roam-search))

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

;; =============================
;; 自定义函数
;; =============================

(defun emarccs-shared-update-link-description ()
  "Update the description of the link at point to match the title of the corresponding Org-roam node in the database.
  If the link is not an Org-roam ID link or the node cannot be found, display an appropriate message without making changes."
  (interactive)
  (require 'org-roam)
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
      (message "The cursor is not on a link."))))

(provide 'emarccs-shared-org-roam)
;;; emarccs-shared-org-roam.el ends here

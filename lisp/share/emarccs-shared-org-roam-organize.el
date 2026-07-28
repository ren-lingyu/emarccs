;;; emarccs-shared-org-roam-organize.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

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
               :template '((path . "${slug}.org")
                           (keywords . ((author . "Lingyu Ren")
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
               :template '((path . "${citar-key}.org")
                           (properties . ((roam_refs . "@${citar-key}")))
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
               :template '((path . "${slug}.org")
                           (keywords . ((author . "Lingyu Ren")
                                        (date . "<%<%Y-%m-%d %A %H:%M:%S %z>>")
                                        (description . nil)
                                        (filetags . ("zettel"))))))
         (list :name "note"
               :tag "note"
               :basic nil
               :directory "permanent"
               :inbox "Not be Classified"
               :template '((path . "${slug}.org")
                           (keywords . ((author . "Lingyu Ren")
                                        (date . "<%<%Y-%m-%d %A %H:%M:%S %z>>")
                                        (description . nil)
                                        (filetags . ("zettel" "note"))))))
         (list :name "blog"
               :tag "blog"
               :basic nil
               :directory "permanent"
               :inbox "Not be Classified"
               :template '((path . "${slug}.org")
                           (keywords . ((author . "aRenCoco")
                                        (date . "<%<%Y-%m-%d %a %z>>")
                                        (email . "aRen_Coco@outlook.com")
                                        (description . nil)
                                        (filetags . ("zettel" "blog"))))))))
  (org-roam-organize-moc-managed-tag-property "MOC_MANAGED_TAG")
  (org-roam-organize-moc-managed-node-count-property "MOC_MANAGED_NODE_COUNT")
  :config
  (with-eval-after-load 'citar-org-roam
    (defun emarccs-shared--org-roam-literature-node-from-citekey (key)
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
             (existing_node (emarccs-shared--org-roam-literature-node-from-citekey key)))
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
   ("C-c o n c" . org-roam-organize-node-create)
   ("C-c o m m" . org-roam-organize-moc-open-index)
   ("C-c o m c" . org-roam-organize-moc-create)
   ("C-c o m s" . org-roam-organize-moc-sync)
   ("C-c o c c" . org-roam-organize-cite-check)
   ("C-c o c s" . org-roam-organize-cite-sync))
  :hook
  ((after-init . org-roam-organize-mode)))

;; citar
(use-package citar
  :after org
  :custom
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography org-cite-global-bibliography)
  (citar-templates '((main . "| ${=type=:12} | ${title} | ${year issued date} | ${author editor:%etal:} |")
                     (suffix . "${abstract}")
                     (preview . "${author editor:%etal} (${year issued date}) ${title}, ${journal}.\n")
                     (note . "Notes on ${author editor:%etal}, ${title}")))
  (citar-format-reference '((author . (:style " %s" :fallback ""))
                            (title . (:style " “%s”" :fallback ""))
                            (year . (:style " (%s)" :fallback ""))
                            (key . (:style " [%s]" :fallback ""))
                            (type . (:style " [%s]" :fallback ""))
                            (abstract . (:style "\n%s" :fallback "")))))

(with-eval-after-load 'citar
  (setq citar-notes-paths
        (list (expand-file-name "./literature/" org-roam-directory))
        citar-library-paths nil)
  (setq citar-bibliography
        (list (expand-file-name "./texmf/bibtex/bib/org-citar.bib" org-directory))))

(use-package citar-embark
  :after (citar embark)
  :config
  (citar-embark-mode))

(use-package citar-org-roam
  :after (org org-roam citar)
  :custom
  (citar-org-roam-mode t)
  :config
  (setq citar-org-roam-subdir "literature")
  (setq citar-org-roam-template-fields
        '((:citar-title . ("title"))
          (:citar-author . ("author" "editor"))
          (:citar-year . ("year"))
          (:citar-month . ("month"))
          (:citar-doi . ("doi"))
          (:citar-isbn . ("isbn"))
          (:citar-url . ("url"))))
  (setq citar-org-roam-note-title-template "${title}"))

(provide 'emarccs-shared-org-roam-organize)

;;; emarccs-shared-org-roam-organize.el ends here

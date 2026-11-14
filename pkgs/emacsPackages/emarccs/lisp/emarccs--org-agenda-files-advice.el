;;; emarccs--org-agenda-files-advice.el -*- lexical-binding: t; -*-

(require 'cl-lib)

(defvar org-directory)
(defvar org-agenda-files)
(declare-function org-read-agenda-file-list "org"
                  (&optional pair-with-expansion))

(defun emarccs--org-agenda-files-advice (excluded-patterns)
  "Return an agenda advice excluding EXCLUDED-PATTERNS.

Recursively expand directory sources while preserving Org's
restriction, archive, file matching and unavailable file handling.
Only recursively discovered directories are subject to the
exclusions; explicit entries remain valid."
  (lambda (original &optional unrestricted archives)
    (if (or (and (not unrestricted)
                 (get 'org-agenda-files 'org-restrict))
            (not
             (or (listp org-agenda-files)
                 (stringp org-agenda-files))))
        (funcall original unrestricted archives)
      (let ((excluded
             (mapcan
              (lambda (pattern)
                (mapcar
                 #'directory-file-name
                 (file-expand-wildcards
                  (expand-file-name pattern org-directory)
                  t)))
              excluded-patterns))
            (entries
             (if (stringp org-agenda-files)
                 (org-read-agenda-file-list)
               org-agenda-files)))
        (cl-labels
         ((expand-directory
           (directory)
           (cons
            directory
            (mapcan
             (lambda (path)
               (when (and (not (member path excluded))
                          (not (file-symlink-p path))
                          (file-directory-p path))
                 (expand-directory path)))
             (directory-files directory t "\\`[^.]")))))
         (let ((org-agenda-files
                (delete-dups
                 (mapcan
                  (lambda (entry)
                    (let ((path
                           (expand-file-name entry org-directory)))
                      (if (file-directory-p path)
                          (expand-directory
                           (directory-file-name path))
                        (list path))))
                  entries))))
           (funcall original unrestricted archives)))))))

(provide 'emarccs--org-agenda-files-advice)

;;; emarccs--org-agenda-files-advice.el ends here.

;;; pre-build.el --- Generate org-version.el -*- lexical-binding: t; -*-

;;; Code:

(require 'lisp-mnt)

(let ((git-version (or (getenv "EMARCCS_ORG_GIT_VERSION")
                       "unknown")))
  (with-temp-file "org-version.el"
    (let* ((org-file
            (cond
             ((file-exists-p "org.el") "org.el")
             ((file-exists-p "lisp/org.el") "lisp/org.el")
             (t (error "Cannot find org.el"))))
           (version
            (with-temp-buffer
              (insert-file-contents org-file)
              (lm-header "version"))))
      (insert
       ";;; org-version.el --- Org version information -*- lexical-binding: t; -*-\n\n"
       (format "(defun org-release () \"The release version of Org.\" %S)\n" version)
       (format "(defun org-git-version () \"The truncate git commit hash of Org mode.\" %S)\n" git-version)
       "(provide 'org-version)\n"))))

;;; pre-build.el ends here

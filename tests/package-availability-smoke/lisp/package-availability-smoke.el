;;; package-availability-smoke.el -*- lexical-binding: t; -*-

(defun emarccs-package-availability-smoke--check (condition message)
  (unless condition
    (error "%s" message)))

(let* ((raw-package-names (or (getenv "PACKAGE_NAMES") ""))
       (package-names (split-string raw-package-names " " t))
       (missing nil))
  (unless package-names
    (error "No declared configuration dependencies supplied"))
  (dolist (package-name package-names)
    (unless (locate-library (if (equal package-name "auctex")
                                "tex-site" package-name))
      (push package-name missing)))
  (when missing
    (error "Missing package libraries: %s"
           (mapconcat #'identity (nreverse missing) ", ")))
  (princ (format "package-availability-smoke ok: %d packages\n"
                 (length package-names))))

;;; package-availability-smoke.el ends here

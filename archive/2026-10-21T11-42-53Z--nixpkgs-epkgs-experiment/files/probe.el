;;; probe.el --- Isolated package load probe -*- lexical-binding: t; -*-
(require 'json)
(require 'seq)
(let* ((name (getenv "EPKGS_TARGET"))
       (library (if (equal name "auctex") "tex-site" name))
       (feature (intern library))
       (path (locate-library library))
       (before (copy-sequence features))
       failure)
  (setq debug-on-error nil)
  (condition-case err
      (progn
        (unless path (error "Library not found: %s" library))
        (require feature))
    (error (setq failure (error-message-string err))))
  (princ (json-encode
          `((package . ,name) (library . ,library) (path . ,path)
            (emacs_version . ,emacs-version)
            (status . ,(if failure "fail" "pass")) (error . ,failure)
            (new_features . ,(vconcat (mapcar #'symbol-name
              (seq-difference features before))))
            (org_version . ,(when (featurep 'org) (org-version)))
            (org_path . ,(when (featurep 'org) (locate-library "org")))
            (epdfinfo . ,(when (boundp 'pdf-info-epdfinfo-program)
                           pdf-info-epdfinfo-program)))))
  (terpri)
  (when failure (kill-emacs 1)))

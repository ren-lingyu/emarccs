;;; runtime.el --- Shared-process and native dependency probes -*- lexical-binding: t; -*-
(require 'json)
(require 'seq)
(defvar epkgs-runtime-results nil)
(defun epkgs-runtime-check (name function)
  (push (condition-case err
            `((test . ,name) (status . "pass") (detail . ,(funcall function)))
          (error `((test . ,name) (status . "fail")
                   (error . ,(error-message-string err)))))
        epkgs-runtime-results))
(epkgs-runtime-check "coexistence"
 (lambda ()
   (let* ((names (append (json-read-file (getenv "EPKGS_LIST")) nil))
          (names (if (getenv "EPKGS_REVERSE") (reverse names) names)))
     (dolist (name names)
       (require (intern (if (equal name "auctex") "tex-site" name))))
     "All 69 entry features loaded in one process")))
(epkgs-runtime-check "org-parse"
 (lambda ()
   (require 'org)
   (with-temp-buffer
     (insert "* Heading\nBody\n")
     (org-mode)
     (unless (= 1 (length (org-element-map (org-element-parse-buffer) 'headline #'identity)))
       (error "Unexpected parse result")))
   (org-version)))
(epkgs-runtime-check "org-roam-sqlite"
 (lambda ()
   (require 'org-roam)
   (let* ((org-roam-directory (make-temp-file "roam-nodes-" t))
          (org-roam-db-location (expand-file-name "roam.db" temporary-file-directory)))
     (unwind-protect
         (let ((result (org-roam-db-query [:select 1])))
           (unless (equal result '((1))) (error "Unexpected SQL result: %S" result))
           (format "%S" result))
       (org-roam-db--close-all)))))
(epkgs-runtime-check "pdf-tools-helper"
 (lambda ()
   (require 'pdf-info)
   (pdf-info-check-epdfinfo)
   (let ((pages (pdf-info-number-of-pages (getenv "EPKGS_PDF"))))
     (unless (= pages 1) (error "Unexpected PDF page count: %S" pages))
     (pdf-info-close (getenv "EPKGS_PDF"))
     pdf-info-epdfinfo-program)))
(epkgs-runtime-check "auctex-mode"
 (lambda ()
   (require 'tex-site)
   (with-temp-buffer (LaTeX-mode) (symbol-name major-mode))))
(princ (json-encode
 `((checks . ,(vconcat (reverse epkgs-runtime-results)))
   (emacs_version . ,emacs-version)
   (org_version . ,(when (featurep 'org) (org-version)))
   (org_path . ,(locate-library "org"))
   (tools . ,(vconcat
      (mapcar (lambda (name) `((name . ,name) (path . ,(executable-find name))))
        '("rg" "git" "diff" "find" "latex" "sbcl" "epdfinfo"))))
   (treesit_available . ,(if (treesit-available-p) t :json-false))
   (grammar_path . ,(vconcat treesit-extra-load-path))
   (grammars . ,(vconcat
      (mapcar (lambda (language)
                `((language . ,(symbol-name language))
                  (available . ,(if (treesit-language-available-p language) t :json-false))))
              '(nix haskell bash json python)))))))
(terpri)

(when (seq-some (lambda (result) (equal (alist-get 'status result) "fail"))
                epkgs-runtime-results)
  (kill-emacs 1))

;;; emarccs-package-lint.el --- Lint all Emarccs source libraries -*- lexical-binding: t; -*-

(require 'package-lint)

(defconst emarccs-package-lint--configuration-exemptions
  '((error . "This key sequence is reserved (see Key Binding Conventions in the Emacs Lisp manual)")
    (warning . "`with-eval-after-load' is for use in configurations, and should rarely be used in packages."))
  "Approved diagnostics for the existing personal configuration modules.
All other diagnostics are failures.  The package entry and initialization
interfaces do not receive these exemptions.")

(let* ((source (or (getenv "EMARCCS_ELISP_SOURCE")
                   (error "EMARCCS_ELISP_SOURCE is not set")))
       (main-file (expand-file-name "emarccs.el" source))
       (interfaces '("emarccs.el" "emarccs-early-init.el" "emarccs-init.el"))
       (files (sort (directory-files-recursively
                     source "\\.el\\'")
                    #'string<))
       (accepted 0)
       (failures 0))
  (unless (file-exists-p main-file)
    (error "Missing Emarccs main library: %s" main-file))
  (dolist (file files)
    (with-temp-buffer
      (insert-file-contents file t)
      (emacs-lisp-mode)
      (setq-local package-lint-main-file main-file)
      (pcase-dolist (`(,line ,column ,severity ,message) (package-lint-buffer))
        (let ((exempt (and (not (member (file-name-nondirectory file) interfaces))
                           (member (cons severity message)
                                   emarccs-package-lint--configuration-exemptions))))
          (if exempt (setq accepted (1+ accepted))
            (setq failures (1+ failures)))
          (message "%s:%d:%d: %s: %s%s"
                   (file-relative-name file source) line column severity message
                   (if exempt " [accepted personal-configuration diagnostic]" ""))))))
  (message "package-lint: %d files, %d approved diagnostics, %d failures"
           (length files) accepted failures)
  (when (> failures 0)
    (error "Emarccs package-lint failed with %d diagnostics" failures)))

;;; emarccs-package-lint.el ends here

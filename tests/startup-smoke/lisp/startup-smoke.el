;;; startup-smoke.el -*- lexical-binding: t; -*-

(defun emarccs-startup-smoke--check (condition message)
  (unless condition
    (error "%s" message)))

(let ((minver (or (getenv "MIN_EMACS_VERSION") "31.0")))
  (princ (format "emacs-version %s\n" emacs-version))
  (when (version< emacs-version minver)
    (display-warning
     'emarccs-test
     (format "This wrapper is only tested with Emacs %s or newer; current Emacs is %s."
             minver emacs-version)
     :warning)))

(require 'emarccs-bootstrap)

(emarccs-startup-smoke--check
 (featurep 'emarccs-bootstrap)
 "emarccs-bootstrap was not loaded")

(emarccs-startup-smoke--check
 (locate-library "emarccs-init")
 "emarccs-init is not locatable")

(princ "startup-smoke ok\n")

;;; startup-smoke.el ends here

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

(require 'emarccs-twist)

(emarccs-startup-smoke--check
 (featurep 'emarccs-twist)
 "emarccs-twist was not loaded")

(emarccs-startup-smoke--check
 (locate-library "emarccs-shared")
 "emarccs-shared is not locatable")

(emarccs-startup-smoke--check
 (seq-some (lambda (path)
             (string-match-p "twist-emacs" path))
           load-path)
 "twist-emacs is missing from load-path")

(emarccs-startup-smoke--check
 (seq-some (lambda (path)
             (string-match-p "-share" path))
           load-path)
 "share is missing from load-path")

(princ "startup-smoke ok\n")

;;; startup-smoke.el ends here

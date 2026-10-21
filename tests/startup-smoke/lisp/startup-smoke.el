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

(emarccs-startup-smoke--check
 (featurep 'emarccs)
 "emarccs was not loaded by site-start.el")

(emarccs-startup-smoke--check
 (advice-member-p 'emarccs-startup 'startup--load-user-init-file)
 "emarccs startup advice was not registered")

(dolist (function '(emarccs-initialize-early emarccs-initialize))
  (emarccs-startup-smoke--check
   (fboundp function)
   (format "%s is not defined" function)))

(emarccs-startup-smoke--check
 (not (or emarccs--early-initialized emarccs--initialized))
 "Emarccs configuration ran during batch site-start")

(princ "startup-smoke ok\n")

;;; startup-smoke.el ends here

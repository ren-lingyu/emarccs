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

;; Batch/-q disables user init, so the wrapper must leave config untouched.
(emarccs-startup-smoke--check
 (not (featurep 'emarccs))
 "Emarccs was initialized despite disabled user init")
(emarccs-startup-smoke--check
 (not (memq 'emarccs-initialize before-init-hook))
 "Emarccs hook was registered despite disabled user init")

(let ((library (locate-library "emarccs"))
      (package-directory (or (getenv "EMARCCS_PACKAGE_DIRECTORY")
                             (error "EMARCCS_PACKAGE_DIRECTORY is not set"))))
  (emarccs-startup-smoke--check
   (and library (file-in-directory-p (file-truename library)
                                    (file-truename package-directory)))
   "Emarccs did not resolve to the supplied installed configuration package"))

(require 'emarccs)
(dolist (function '(emarccs-initialize-early emarccs-initialize))
  (emarccs-startup-smoke--check
   (fboundp function)
   (format "%s is not defined" function)))
(emarccs-startup-smoke--check
 (not (or emarccs--early-initialized emarccs--initialized))
 "Requiring Emarccs ran configuration")
(emarccs-startup-smoke--check
 (not (memq 'emarccs-initialize before-init-hook))
 "Requiring Emarccs registered startup scheduling")

;; A clean incoming PATH must still find the programs supplied by the wrapper.
(dolist (program '(("grep" . "EMARCCS_GREP")
                   ("rg" . "EMARCCS_RG")
                   ("ls" . "EMARCCS_LS")))
  (let ((actual (executable-find (car program)))
        (expected (or (getenv (cdr program))
                      (error "%s is not set" (cdr program)))))
    (emarccs-startup-smoke--check
     (and actual (file-equal-p actual expected))
     (format "%s did not resolve to the supplied system program: %S"
             (car program) actual))))

;; Exercise real package activation in a fresh batch process without ERT or an
;; explicit cl-lib preload.  Replace only personal configuration initializers.
(let ((init-file-user "activation-test")
      (before-init-hook nil)
      (early-called nil)
      (regular-called nil)
      (warnings nil)
      (original-early (symbol-function 'emarccs-initialize-early))
      (original-init (symbol-function 'emarccs-initialize))
      (original-warning (symbol-function 'display-warning))
      forms)
  (with-temp-buffer
    (insert-file-contents (or (getenv "EMARCCS_SITE_START")
                             (error "EMARCCS_SITE_START is not set")))
    (goto-char (point-min))
    (condition-case nil
        (while t
          (let ((form (read (current-buffer))))
            (when (and (consp form) (eq (car form) 'when)
                       (eq (cadr form) 'init-file-user))
              (push form forms))))
      (end-of-file nil)))
  (emarccs-startup-smoke--check
   (= (length forms) 1) "Expected one wrapper startup form")
  (unwind-protect
      (progn
        (fset 'emarccs-initialize-early (lambda () (setq early-called t)))
        (fset 'emarccs-initialize (lambda () (setq regular-called t)))
        (fset 'display-warning
              (lambda (type message &optional level _buffer)
                (push (list type message level) warnings)))
        (eval (car forms) t)
        (emarccs-startup-smoke--check early-called "Early initializer was skipped")
        (run-hooks 'before-init-hook)
        (emarccs-startup-smoke--check regular-called "Regular initializer was skipped"))
    (fset 'emarccs-initialize-early original-early)
    (fset 'emarccs-initialize original-init)
    (fset 'display-warning original-warning))
  (dolist (package '(citar consult org))
    (emarccs-startup-smoke--check
     (memq package package-activated-list)
     (format "%s was not activated" package)))
  (dolist (warning warnings)
    (when (eq (nth 2 warning) :error)
      (error "Package activation error: %S" warning))))

(princ "startup-smoke ok\n")

;;; startup-smoke.el ends here

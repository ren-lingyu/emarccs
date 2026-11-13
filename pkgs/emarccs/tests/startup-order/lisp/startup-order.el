;;; startup-order.el --- Test installed wrapper scheduling -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'package)

(defvar emarccs-startup-order--events nil)

;; -Q excludes wrapper startup: load only the explicitly supplied installed
;; configuration interfaces.  Never fall back to the project's source tree.
(let* ((directory
        (or (getenv "EMARCCS_PACKAGE_DIRECTORY")
            (error "EMARCCS_PACKAGE_DIRECTORY is not set")))
       (libraries
        (directory-files-recursively
         directory "\\`emarccs\\.elc?\\'"))
       (directories
        (delete-dups (mapcar #'file-name-directory libraries))))
  (unless (= (length directories) 1)
    (error "Expected one installed Emarccs library directory: %S"
           directories))
  (add-to-list 'load-path (car directories)))

(defun emarccs-startup-order--startup-form ()
  "Read the actual wrapper's Emarccs startup form, without executing startup."
  (with-temp-buffer
    (insert-file-contents
     (or (getenv "EMARCCS_SITE_START")
         (error "EMARCCS_SITE_START is not set")))
    (goto-char (point-min))
    (let (forms)
      (condition-case nil
          (while t
            (let ((form (read (current-buffer))))
              (when (and (consp form)
                         (eq (car form) 'when)
                         (eq (cadr form) 'init-file-user))
                (push form forms))))
        (end-of-file
         nil))
      (should (= (length forms) 1))
      (car forms))))

(ert-deftest emarccs-startup-order--wrapper-phases ()
  "Actual site-start schedules early config and regular config before user init."
  (require 'emarccs)
  (let ((init-file-user "test-user")
        (before-init-hook nil)
        (emarccs-startup-order--events nil)
        (original-require (symbol-function 'require)))
    (cl-letf (((symbol-function 'package-activate-all)
               (lambda ()
                 (push 'activate emarccs-startup-order--events)))
              ((symbol-function 'require)
               (lambda (feature &optional filename noerror)
                 (when (eq feature 'emarccs)
                   (push 'entry emarccs-startup-order--events))
                 (funcall original-require feature filename noerror)))
              ((symbol-function 'emarccs-initialize-early)
               (lambda ()
                 (push 'early emarccs-startup-order--events)))
              ((symbol-function 'emarccs-initialize)
               (lambda ()
                 (push 'regular emarccs-startup-order--events))))
      (eval (emarccs-startup-order--startup-form) t)
      (should
       (equal
        (reverse emarccs-startup-order--events)
        '(activate entry early)))
      ;; Model the native phases without launching interactive Emacs.
      (push 'user-early emarccs-startup-order--events)
      (run-hooks 'before-init-hook)
      (push 'user-init emarccs-startup-order--events)
      (should
       (equal
        (reverse emarccs-startup-order--events)
        '(activate entry early user-early regular user-init))))))

(ert-deftest emarccs-startup-order--wrapper-hook-is-unique ()
  "Repeated site-start evaluation does not stack the regular initializer."
  (require 'emarccs)
  (let ((init-file-user "test-user")
        (before-init-hook nil))
    (cl-letf (((symbol-function 'package-activate-all) #'ignore)
              ((symbol-function 'emarccs-initialize-early) #'ignore))
      (dotimes (_run 2)
        (eval (emarccs-startup-order--startup-form) t)))
    (should (equal before-init-hook '(emarccs-initialize)))))

(ert-deftest emarccs-startup-order--skip-without-user-init ()
  "Disabled user initialization does not activate packages or schedule config."
  (let ((init-file-user nil)
        (before-init-hook nil))
    (let ((form (emarccs-startup-order--startup-form)))
      (cl-letf (((symbol-function 'package-activate-all)
                 (lambda ()
                   (ert-fail "Unexpected package activation")))
                ((symbol-function 'require)
                 (lambda (&rest _)
                   (ert-fail "Unexpected library load")))
                ((symbol-function 'emarccs-initialize-early)
                 (lambda ()
                   (ert-fail "Unexpected early initialization"))))
        (eval form t)))
    (should-not before-init-hook)))

;;; startup-order.el ends here

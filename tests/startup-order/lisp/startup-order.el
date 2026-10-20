;;; startup-order.el --- Test Emarccs bootstrap phases -*- lexical-binding: t; -*-

(require 'ert)
(require 'emarccs-bootstrap)

(defvar emarccs-startup-order--events nil
  "Events recorded by startup order test fixtures.")

(defun emarccs-startup-order--check-phases ()
  "Check adapter phase ordering using isolated temporary fixtures."
  (should-not (featurep 'emarccs-startup-order-main-fixture))
  (let* ((fixture-dir (make-temp-file "emarccs-startup-order-" t))
         (early-file (expand-file-name "early.el" fixture-dir))
         (main-file (expand-file-name "emarccs-startup-order-main-fixture.el" fixture-dir))
         (load-path (cons fixture-dir load-path))
         (init-file-user "test-user")
         (emarccs-startup-order--events nil))
    (unwind-protect
        (progn
          (with-temp-file early-file
            (insert "(push 'emarccs-early emarccs-startup-order--events)\n"))
          (with-temp-file main-file
            (insert "(push 'emarccs-main emarccs-startup-order--events)\n"
                    "(provide 'emarccs-startup-order-main-fixture)\n"))
          (let ((advice (emarccs-bootstrap--load-user-init-file
                         early-file 'emarccs-startup-order-main-fixture))
                (alternate (lambda () "alternate-init.el")))
            (should
             (eq (funcall advice
                     (lambda (filename-function alternate-filename-function load-defaults)
                       (should (equal (funcall filename-function) "user-early.el"))
                       (should (eq alternate-filename-function alternate))
                       (should (null load-defaults))
                       (push 'user-early emarccs-startup-order--events)
                       'early-result)
                     (lambda () "user-early.el") alternate nil)
                 'early-result))
            (should
             (eq (funcall advice
                     (lambda (filename-function alternate-filename-function load-defaults)
                       (should (equal (funcall filename-function) "user-init.el"))
                       (should (eq alternate-filename-function alternate))
                       (should (eq load-defaults t))
                       (push 'user-init emarccs-startup-order--events)
                       'init-result)
                     (lambda () "user-init.el") alternate t)
                 'init-result)))
          (should (equal (nreverse emarccs-startup-order--events)
                         '(emarccs-early user-early emarccs-main user-init))))
      ;; Unload only our fixture.  Loading Lisp can legitimately load other
      ;; libraries, so restoring the entire feature/history lists is unsafe.
      (unwind-protect
          (when (featurep 'emarccs-startup-order-main-fixture)
            (unload-feature 'emarccs-startup-order-main-fixture t))
        (setq load-history
              (assoc-delete-all main-file
                                (assoc-delete-all early-file load-history)))
        (delete-directory fixture-dir t)))))

(ert-deftest emarccs-startup-order--adapter-phases ()
  "Check ordering, forwarding and fixture isolation across repeated runs."
  (let ((original-load-path load-path))
    (dotimes (_run 2)
      (emarccs-startup-order--check-phases)
      (should-not (featurep 'emarccs-startup-order-main-fixture))
      (should (eq load-path original-load-path)))))

(ert-deftest emarccs-startup-order--skip-without-user-init ()
  "Check that no config is loaded when user init is disabled."
  (let ((init-file-user nil)
        (emarccs-startup-order--events nil)
        (advice (emarccs-bootstrap--load-user-init-file
                 "/missing/early.el" 'emarccs-startup-order-missing-fixture)))
    (dolist (phase '(nil t))
      (let* ((filename-function (lambda () "unused-init.el"))
             (alternate (lambda () "unused-alternate.el"))
             (result (make-symbol "original-result")))
        (should
         (eq (funcall advice
                      (lambda (filename alternate-filename load-defaults)
                        (should (eq filename filename-function))
                        (should (eq alternate-filename alternate))
                        (should (eq load-defaults phase))
                        (push 'original emarccs-startup-order--events)
                        result)
                      filename-function alternate phase)
             result))))
    (should (equal emarccs-startup-order--events '(original original)))))

;;; startup-order.el ends here

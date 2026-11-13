;;; initialization.el --- Test configuration initialization -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'package)

(defvar emarccs--early-initialized)
(defvar emarccs--initialized)
(defvar emarccs--initializing)
(defvar use-package-always-ensure)
(defvar native-comp-async-report-warnings-errors)
(defvar emarccs-startup-order--custom-loads 0)

(ert-deftest emarccs-startup-order--entry-is-lazy ()
  "Loading/reloading interfaces neither configures Emacs nor schedules startup."
  (let ((emarccs--early-initialized nil)
        (emarccs--initialized nil)
        (emarccs--initializing nil)
        (before-init-hook nil)
        (package-enable-at-startup 'unchanged)
        (default-frame-alist '((unchanged . default)))
        (initial-frame-alist '((unchanged . initial)))
        (frame-resize-pixelwise nil)
        (blink-cursor-mode t)
        (custom-file "unchanged-custom.el")
        (use-package-always-ensure 'unchanged)
        (original-require (symbol-function 'require))
        required)
    (cl-letf (((symbol-function 'require)
               (lambda (feature &optional filename noerror)
                 (push feature required)
                 (funcall original-require
                          feature
                          filename
                          noerror))))
      (dolist (library
               '("emarccs-early-init"
                 "emarccs-init"
                 "emarccs"
                 "emarccs"))
        (load (locate-library library) nil t)))
    (dolist (feature
             '(use-package org
                auctex
                emarccs-basic
                emarccs-org))
      (should-not (memq feature required)))
    (should-not before-init-hook)
    (should-not emarccs--early-initialized)
    (should-not emarccs--initialized)
    (should-not emarccs--initializing)
    (should (eq package-enable-at-startup 'unchanged))
    (should (equal default-frame-alist '((unchanged . default))))
    (should (equal initial-frame-alist '((unchanged . initial))))
    (should-not frame-resize-pixelwise)
    (should blink-cursor-mode)
    (should (equal custom-file "unchanged-custom.el"))
    (should (eq use-package-always-ensure 'unchanged))))

(ert-deftest emarccs-startup-order--early-initializes-once ()
  "Early initialization applies settings once and preserves later overrides."
  (require 'emarccs-early-init)
  (let ((emarccs--early-initialized nil)
        (package-enable-at-startup t)
        (native-comp-async-report-warnings-errors t)
        (default-frame-alist nil)
        (initial-frame-alist nil)
        (frame-resize-pixelwise nil)
        (blink-cursor-mode t))
    (emarccs-initialize-early)
    (should emarccs--early-initialized)
    (should-not package-enable-at-startup)
    (should (eq native-comp-async-report-warnings-errors 'silent))
    (should frame-resize-pixelwise)
    (should-not blink-cursor-mode)
    (should
     (eq (alist-get 'fullscreen default-frame-alist) 'maximized))
    (should
     (equal
      (alist-get 'background-color initial-frame-alist) "gray10"))
    (setq default-frame-alist '((user . override)))
    (emarccs-initialize-early)
    (should (equal default-frame-alist '((user . override))))))

(ert-deftest emarccs-startup-order--regular-initializes-once ()
  "Preserve module order and run custom.el once, including recursive calls."
  (require 'emarccs-init)
  (let ((fixture-dir (make-temp-file "emarccs-custom-" t))
        (emarccs--initialized nil)
        (emarccs--initializing nil)
        (emarccs-startup-order--custom-loads 0)
        (use-package-always-ensure t)
        (custom-file "unchanged")
        required)
    (unwind-protect
        (let ((user-emacs-directory
               (file-name-as-directory fixture-dir)))
          (with-temp-file (expand-file-name "custom.el" fixture-dir)
            (insert
             ";;; -*- lexical-binding: t; -*-\n"
             "(setq emarccs-startup-order--custom-loads\n"
             "      (1+ emarccs-startup-order--custom-loads))\n"
             "(emarccs-initialize)\n"))
          (cl-letf (((symbol-function 'require)
                     (lambda (feature &optional _filename _noerror)
                       (push feature required)
                       ;; Reenter before initialization has completed.
                       (emarccs-initialize)
                       feature)))
            (emarccs-initialize)
            (emarccs-initialize))
          (should emarccs--initialized)
          (should-not emarccs--initializing)
          (should-not use-package-always-ensure)
          (should
           (equal
            custom-file (expand-file-name "custom.el" fixture-dir)))
          (should (= emarccs-startup-order--custom-loads 1))
          (should
           (equal
            (nreverse required)
            '(use-package emarccs-basic
               emarccs-help
               emarccs-theme
               emarccs-org
               emarccs-tex
               emarccs-complete
               emarccs-lisp
               emarccs-org-roam
               emarccs-org-roam-organize
               emarccs-org-latex-preview
               emarccs-feed
               emarccs-org-roam-blog
               emarccs-debug))))
      (delete-directory fixture-dir t))))

(ert-deftest emarccs-startup-order--failed-initialization-can-retry ()
  "An initialization error does not leave either guard stuck."
  (require 'emarccs-init)
  (let ((emarccs--initialized nil)
        (emarccs--initializing nil)
        (use-package-always-ensure t)
        (custom-file nil)
        (user-emacs-directory (make-temp-file "emarccs-retry-" t))
        (fail t))
    (unwind-protect
        (cl-letf (((symbol-function 'require)
                   (lambda (feature &optional _filename _noerror)
                     (when (and fail (eq feature 'emarccs-basic))
                       (error "Simulated module failure"))
                     feature)))
          (should-error (emarccs-initialize) :type 'error)
          (should-not emarccs--initialized)
          (should-not emarccs--initializing)
          (setq fail nil)
          (emarccs-initialize)
          (should emarccs--initialized)
          (should-not emarccs--initializing))
      (delete-directory user-emacs-directory t))))

;;; initialization.el ends here

;;; emarccs-lisp.el --- Common Lisp development configuration -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(eval-when-compile
  (require 'use-package))

(use-package sly
  :commands sly
  :custom (inferior-lisp-program "sbcl")
  :hook (lisp-mode . sly-mode))

(provide 'emarccs-lisp)

;;; emarccs-lisp.el ends here

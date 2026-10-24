;;; emarccs-lisp.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(eval-when-compile
  (require 'use-package))

(use-package
 sly
 :commands sly
 :custom (inferior-lisp-program "sbcl")
 :hook (lisp-mode . sly-mode))

(provide 'emarccs-lisp)

;;; emarccs-lisp.el ends here

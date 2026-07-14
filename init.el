;;; init.el -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;; version check
(let ((minver "31.0"))
  (when (version< emacs-version minver)
    (display-warning
     'emarccs
     (format "This configuration is only tested with Emacs %s or newer; current Emacs is %s."
             minver emacs-version)
     :warning)))

;; load-path
(add-to-list 'load-path
             (expand-file-name "lisp/pure-emacs"
                               (file-name-directory (or load-file-name
                                                        buffer-file-name))))

(add-to-list 'load-path
             (expand-file-name "lisp/share"
                               (file-name-directory (or load-file-name
                                                        buffer-file-name))))

;; pure emacs initial settings
(require 'emarccs-pemacs)

;; shared initial settings
(require 'emarccs-shared)

;; end
(provide 'init)

;;; init.el ends here

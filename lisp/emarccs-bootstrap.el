;;; emarccs-bootstrap.el --- Load the Emarccs configuration from site-start -*- lexical-binding: t; -*-
;;; Commentary:
;; Required from the wrapper's generated site-start.el.  It must not run the
;; configuration itself, because site-start runs before the early-init phase.
;; It only defines the advice that loads the early-init settings and the
;; configuration entry at the right phases of `startup--load-user-init-file'.
;;; Code:

(defun emarccs-bootstrap--load-user-init-file (early-init-file-path init-feature)
  "Return an advice for `startup--load-user-init-file'.
EARLY-INIT-FILE-PATH is loaded before the real user early init file.
INIT-FEATURE is required before the real user init file."
  (lambda (orig-fun filename-function &optional alternate-filename-function load-defaults)
    (when init-file-user
      (if load-defaults
          (require init-feature)
        (load early-init-file-path nil t)))
    (funcall orig-fun filename-function alternate-filename-function load-defaults)))

(provide 'emarccs-bootstrap)

;;; emarccs-bootstrap.el ends here

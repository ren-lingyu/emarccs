;;; emarccs-twist-advice-add.el -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun emarccs-twist--load-user-init-file (early-init-file shared-feature)
  "Return an advice for `startup--load-user-init-file'.
EARLY-INIT-FILE is loaded before the real user early init file.
SHARED-FEATURE is required before the real user init file."
  (lambda (orig-fun filename-function &optional alternate-filename-function load-defaults)
    (when init-file-user
      (if load-defaults
          (require shared-feature)
        (load early-init-file nil t)))
    (funcall orig-fun filename-function alternate-filename-function load-defaults)))

(provide 'emarccs-twist-advice-add)

;;; emarccs-twist-advice-add.el ends here

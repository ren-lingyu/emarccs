;;; emarccs-bootstrap.el --- Adapt Emacs startup phases -*- lexical-binding: t; -*-

;;; Commentary:

;; Define the startup adapter without registering or running it.
;; The main emarccs library owns registration and initialization timing.

;;; Code:

(declare-function emarccs-initialize "emarccs-init" ())
(declare-function emarccs-initialize-early "emarccs-early-init" ())

(defun emarccs-bootstrap--before-user-init-file
    (_filename-function &optional _alternate-filename-function load-defaults)
  "Initialize Emarccs before the corresponding user init file.
LOAD-DEFAULTS selects regular initialization; nil selects early initialization.
Skip both phases when `init-file-user' is nil."
  (when init-file-user
    (if load-defaults
        (emarccs-initialize)
      (emarccs-initialize-early))))

(provide 'emarccs-bootstrap)

;;; emarccs-bootstrap.el ends here

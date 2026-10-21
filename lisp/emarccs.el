;;; emarccs.el --- Personal configuration and startup scheduling -*- lexical-binding: t; -*-

;; Author: ren-lingyu
;; Version: 0.1.0
;; Package-Requires: ((emacs "31.1"))
;; Keywords: convenience
;; URL: https://github.com/ren-lingyu/emarccs
;; SPDX-License-Identifier: MIT

;;; Commentary:

;; Load initialization interfaces and register Emarccs startup scheduling.
;; Requiring this library does not initialize the editor configuration.
;; Third-party packages are still supplied by the existing environment;
;; the dependency header does not yet describe an independent installation.

;;; Code:

(require 'emarccs-bootstrap)
(require 'emarccs-early-init)
(require 'emarccs-init)

(unless (advice-member-p 'emarccs-startup 'startup--load-user-init-file)
  (advice-add 'startup--load-user-init-file :before
              #'emarccs-bootstrap--before-user-init-file
              '((name . emarccs-startup))))

(provide 'emarccs)

;;; emarccs.el ends here

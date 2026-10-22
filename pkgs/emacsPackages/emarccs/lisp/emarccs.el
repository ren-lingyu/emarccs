;;; emarccs.el --- Personal configuration initialization interfaces -*- lexical-binding: t; -*-

;; Author: ren-lingyu
;; Version: 0.1.0
;; Package-Requires: ((emacs "31.1"))
;; Keywords: convenience
;; URL: https://github.com/ren-lingyu/emarccs
;; SPDX-License-Identifier: MIT

;;; Commentary:

;; Load the early and regular initialization interfaces.
;; The Emacs wrapper owns startup scheduling.
;; Requiring this library does not initialize the editor configuration.
;; Third-party packages are still supplied by the existing environment;
;; the dependency header does not yet describe an independent installation.

;;; Code:

(require 'emarccs-early-init)
(require 'emarccs-init)

(provide 'emarccs)

;;; emarccs.el ends here

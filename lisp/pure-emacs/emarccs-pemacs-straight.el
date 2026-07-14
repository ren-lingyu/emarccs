;;; emarccs-pemacs-straight.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

;; straight variables
(setq straight-use-package-by-default t)
(setq straight-repository-branch "main")
(setq straight-vc-git-default-clone-depth 1) ; 使用浅克隆
(setq straight-vc-git-default-protocol 'https)
;; (setq straight-host-usernames '((github . "git")))
;; (setq straight-check-for-modifications '(check-on-save))

;; straight bootstrap
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; use-package
(straight-use-package 'use-package)
(eval-when-compile (require 'use-package))

;; straight registers
(dolist (recipe '((dired :type built-in)
                  (dired-x :type built-in)))
  (straight-register-package recipe))

(let* ((current-file (or load-file-name
                         buffer-file-name
                         (error "Cannot determine the current file")))
       (current-directory (file-name-directory current-file))
       (recipe-pattern (expand-file-name "../../pkgs/*/straight-register.el"
                                         current-directory))
       (recipe-files (file-expand-wildcards recipe-pattern
                                            'full)))
  (dolist (recipe-file recipe-files)
    (with-temp-buffer (insert-file-contents recipe-file)
                      (goto-char (point-min))
                      (let ((recipe (condition-case nil (read (current-buffer))
                                      (end-of-file (error "Empty recipe file: %s" recipe-file)))))
                        (straight-register-package recipe)))))

;; end
(provide 'emarccs-pemacs-straight)

;;; emarccs-pemacs-straight.el ends here

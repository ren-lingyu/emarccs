;;; emarccs-shared-theme.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

;; Koishi theme
(use-package koishi-theme
  :config
  (unless (custom-theme-enabled-p 'koishi)
    (load-theme 'koishi t)))


;; Modus themes
(use-package modus-themes
  :custom
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t))


;; Doom modeline
(use-package doom-modeline
  :custom
  (doom-modeline-icon nil)

  :config
  (unless doom-modeline-mode
    (doom-modeline-mode 1)))


(provide 'emarccs-shared-theme)

;;; emarccs-shared-theme.el ends here

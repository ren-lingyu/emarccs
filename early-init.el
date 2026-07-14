;;; early-init.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(setq package-enable-at-startup nil)

(setq native-comp-async-report-warnings-errors 'silent)

;; 初始外观
(setq frame-resize-pixelwise t)

(setq blink-cursor-mode nil)

(setq default-frame-alist
      '((background-color . "gray10")
        (foreground-color . "gray90")
        (fullscreen . maximized)
        (vertical-scroll-bars . nil)
        (menu-bar-lines . 0)
        (tool-bar-lines . 0)))

(setq initial-frame-alist default-frame-alist)

(provide 'early-init)

;;; early-init.el ends here

;;; early-init.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(setq package-enable-at-startup nil)

(setq native-comp-async-report-warnings-errors 'silent)

;; 初始外观
(setq frame-resize-pixelwise t)

(setq blink-cursor-mode nil)

;; 所有 frame 的长期默认设置
(setq default-frame-alist
      '((fullscreen . maximized)
        (vertical-scroll-bars . nil)
        (menu-bar-lines . 0)
        (tool-bar-lines . 0)))

;; 仅用于启动时第一个 frame 的 bootstrap 外观
(setq initial-frame-alist
      '((background-color . "gray10")
        (foreground-color . "gray90")
        (fullscreen . maximized)
        (vertical-scroll-bars . nil)
        (menu-bar-lines . 0)
        (tool-bar-lines . 0)))

(provide 'early-init)

;;; early-init.el ends here

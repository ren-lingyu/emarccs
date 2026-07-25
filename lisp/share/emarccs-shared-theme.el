;;; emarccs-shared-theme.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(use-package koishi-theme
  :init
  ;; set `koishi-theme-mode' to t if you want to use light theme,
  ;; this variable should be configured before you load theme.
  (setq koishi-theme-mode nil)
  ;; enable koishi theme
  (load-theme 'koishi t)
  (unless (or (daemonp) (display-graphic-p))
    (setf (alist-get 'background-color default-frame-alist) nil))
  :hook
  ((server-after-make-frame . (lambda () (load-theme 'koishi t)))))

;; Modus Themes (官方主题, 终端兼容性最佳)
(use-package modus-themes
  :init
  (load-theme 'modus-vivendi t)
  (setq modus-themes-bold-constructs t)
  (setq modus-themes-italic-constructs t)
  (setq modus-themes-org-blocks 'gray-background)
  (setq modus-themes-region '(accented))
  (setq modus-themes-fringes 'subtle))

;; Doom Themes(可选, 风格时尚)
(use-package doom-themes
  :init
  ;; (load-theme 'doom-one t)
  (load-theme 'doom-gruvbox t)
  ;; (load-theme 'doom-solarized-dark t)
  ;; (load-theme 'doom-nord t)
  ;; (load-theme 'doom-dracula t)
  (setq doom-themes-enable-bold t)
  (setq doom-themes-enable-italic t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; Doom Modeline (可选)
(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  (setq doom-modeline-icon nil))


(use-package catppuccin-theme
  :init
  ;; 可选项: 设置风味 (Mocha 深色, Latte 浅色, Frappe 中间色, Macchiato 偏暗)
  (setq catppuccin-flavor 'mocha)
  (setq catppuccin-enable-bold t)
  (setq catppuccin-enable-italic t)
  (setq catppuccin-highlight-matches t)
  (setq catppuccin-colorize-comments t)
  (setq catppuccin-colorize-org-headings t)
  (setq catppuccin-colorize-modeline t)
  (load-theme 'catppuccin t))

;; =========================
;; 主题切换配置
;; =========================

;; 所有主题组及子主题 (Catppuccin 风味特殊处理)
(defconst my/theme-groups
  '((koishi koishi)
    (modus modus-vivendi modus-operandi)
    (doom doom-one doom-dracula doom-gruvbox doom-nord doom-solarized-dark)
    (catppuccin mocha latte frappe macchiato))
  "主题组及其子主题(Catppuccin 风味特殊处理)")

;; 当前组索引和主题索引 (初始化完全由这两个变量控制), 切换主题依赖于对这两个变量的重新赋值.
(defvar my/group-index 0 "当前主题组索引")
(defvar my/theme-index 0 "当前主题索引")

(defun my/load-current-theme ()
  "根据组索引和主题索引加载主题"
  ;; 禁用旧主题
  (mapc #'disable-theme custom-enabled-themes)
  (let* ((group (nth my/group-index my/theme-groups))
         (group-name (car group))
         ;; 跳过组名
         (theme (nth (1+ my/theme-index) group)))
    (cond
     ;; Catppuccin 特殊处理
     ((eq group-name 'catppuccin)
      (setq catppuccin-flavor theme)
      (load-theme 'catppuccin t)
      (message "加载 Catppuccin 风味: %s" theme))
     ;; 其他主题直接加载
     (t
      (load-theme theme t)
      (message "加载主题: %s" theme)))))

(defun my/toggle-theme-group ()
  "切换到下一个主题组"
  (interactive)
  (setq my/group-index (mod (1+ my/group-index) (length my/theme-groups))
        my/theme-index 0)
  (my/load-current-theme))

(defun my/toggle-subtheme ()
  "切换当前组的下一个主题"
  (interactive)
  (let ((group (nth my/group-index my/theme-groups)))
    (setq my/theme-index (mod (1+ my/theme-index) (1- (length group))))
    (my/load-current-theme)))

(defun my/show-current-theme ()
  "显示当前主题组和主题名称"
  (interactive)
  (let* ((group (nth my/group-index my/theme-groups))
         (group-name (car group))
         (theme (nth (1+ my/theme-index) group)))
    (message "当前主题组: %s | 当前主题: %s"
             group-name
             (if (eq group-name 'catppuccin)
                 (format "Catppuccin (%s)" theme)
               theme))))

;; 快捷键绑定
(global-set-key (kbd "<f4>") #'my/toggle-theme-group)
(global-set-key (kbd "<f5>") #'my/toggle-subtheme)
(global-set-key (kbd "<f6>") #'my/show-current-theme)

;; 初始化加载主题
(my/load-current-theme)


(provide 'emarccs-shared-theme)
;;; emarccs-shared-theme.el ends here.

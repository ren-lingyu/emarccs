;;; emarccs-basic.el --- Basic editor configuration -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(eval-when-compile
  (require 'use-package))

(setenv "TZ" "Asia/Shanghai")

;; 启动界面
(setq inhibit-startup-screen t)
(setq initial-buffer-choice t)

;; 字体与窗口尺寸
(defun emarccs-basic--frame-alist-with-geometry (alist width height)
  "Return ALIST with WIDTH and HEIGHT in text pixels, without modifying ALIST."
  (append
   `((width . (text-pixels . ,width))
     (height . (text-pixels . ,height)))
   (assq-delete-all
    'width (assq-delete-all 'height (copy-sequence alist)))))

(when (display-graphic-p)
  (let* ((font-height-mm 4)
         (mm-size (frame-monitor-attribute 'mm-size))
         (mm-width (and (consp mm-size) (car mm-size)))
         (mm-height
          (and (consp mm-size)
               (if (consp (cdr mm-size))
                   (cadr mm-size)
                 (cdr mm-size))))
         (geometry (frame-monitor-attribute 'geometry))
         (monitor-width (nth 2 geometry))
         (monitor-height (nth 3 geometry))
         (base-width 1920.0)
         (base-height 1080.0)
         (base-font-height 110)
         (valid-geometry-p
          (and (numberp monitor-width)
               (numberp monitor-height)
               (> monitor-width 0)
               (> monitor-height 0)))
         (scale
          (when valid-geometry-p
            (min (/ monitor-width base-width)
                 (/ monitor-height base-height))))
         (font-height
          (or (when (and (numberp mm-width)
                         (numberp mm-height)
                         (> mm-width 0)
                         (> mm-height 0))
                (round (* font-height-mm 10 (/ 72.27 25.4))))
              (when scale
                (round (* base-font-height scale)))
              'unspecified)))
    (set-face-attribute 'default nil
                        :height font-height
                        :weight 'regular
                        :width 'normal
                        :family "Maple Mono NF CN")
    (when valid-geometry-p
      (setq default-frame-alist
            (emarccs-basic--frame-alist-with-geometry
             default-frame-alist monitor-width monitor-height)
            initial-frame-alist
            (emarccs-basic--frame-alist-with-geometry
             initial-frame-alist monitor-width monitor-height)))))

(unless (display-graphic-p)
  (setq frame-background-mode 'dark))

;; 编码
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

;; 高亮与符号美化
(show-paren-mode 1) ; 高亮匹配括号
(global-font-lock-mode 1) ; 全局语法高亮
(global-prettify-symbols-mode t) ; 符号美化

;; 行号与列号
(column-number-mode t) ; 在 Mode line 显示列号
(global-display-line-numbers-mode 1) ; 全局显示行号

;; 文件自动重载与选中替换
(global-auto-revert-mode t) ; 文件外部修改自动刷新
(delete-selection-mode t) ; 选中文本后输入替换

;; 缩进
(setq-default indent-tabs-mode nil) ; 默认禁用制表符
(setq-default tab-width 4) ; 默认 tab 宽度为 4 个空格

;; prog-mode hook & conf-mode hook
(add-hook 'prog-mode-hook #'hs-minor-mode) ; 编程模式折叠代码块
(add-hook 'prog-mode-hook #'delete-trailing-whitespace-mode)
(add-hook 'conf-mode-hook #'delete-trailing-whitespace-mode)

;; 退出时保存书签
(add-hook 'bookmark-exit-hook #'bookmark-save)

;; Backup
(setq make-backup-files t)
(setq vc-make-backup-files t)
(setq version-control t)
(setq kept-old-versions 0)
(setq kept-new-versions 20)
(setq delete-old-versions t)
(setq backup-directory-alist
      `((".*" . ,(locate-user-emacs-file "cache/backups/"))))
(dolist (entry backup-directory-alist)
  (make-directory (cdr entry) t))

;; Auto-save
(setq auto-save-default t)
(setq auto-save-file-name-transforms
      `((".*" ,(locate-user-emacs-file "cache/auto-save/") t)))
(dolist (entry auto-save-file-name-transforms)
  (make-directory (cadr entry) t))

;; Lockfiles
(setq create-lockfiles t)

;; 忽略格式风格警告
(setq byte-compile-warnings '(not docstrings))

;; 编译
(use-package compile
  :custom (compilation-scroll-output t))

;; dired
(use-package dired
  :config
  (setq dired-listing-switches
        "-l -a --human-readable --group-directories-first")
  (setq dired-hide-details-mode nil)
  (put 'dired-find-alternate-file 'disabled nil))

(use-package dired-x
  :config (setq dired-omit-files nil))

(use-package dirvish
  :init (dirvish-override-dired-mode)
  :config
  (setq dirvish-hide-details nil)
  (setq dirvish-mode-line-format
        '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-attributes
        '(vc-state subtree-state
                   nerd-icons
                   collapse
                   git-msg
                   file-time
                   file-size))
  (setq dirvish-side-attributes
        '(vc-state nerd-icons collapse file-size))
  (setq dirvish-large-directory-threshold 20000))

(use-package diredfl
  :disabled
  :hook
  ((dired-mode . diredfl-mode)
   (dirvish-directory-view-mode . diredfl-mode))
  :config (set-face-attribute 'diredfl-dir-name nil :bold t))

(use-package dired-rainbow
  :config
  (progn
    (dired-rainbow-define-chmod directory "#6cb2eb" "d.*")
    (dired-rainbow-define
     html "#eb5286"
     ("css"
      "less"
      "sass"
      "scss"
      "htm"
      "html"
      "jhtm"
      "mht"
      "eml"
      "mustache"
      "xhtml"))
    (dired-rainbow-define
     xml "#f2d024"
     ("xml"
      "xsd"
      "xsl"
      "xslt"
      "wsdl"
      "bib"
      "json"
      "msg"
      "pgn"
      "rss"
      "yaml"
      "yml"
      "rdata"))
    (dired-rainbow-define
     document "#9561e2"
     ("docm"
      "doc"
      "docx"
      "odb"
      "odt"
      "pdb"
      "pdf"
      "ps"
      "rtf"
      "djvu"
      "epub"
      "odp"
      "ppt"
      "pptx"))
    (dired-rainbow-define
     markdown "#ffed4a"
     ("org"
      "etx"
      "info"
      "markdown"
      "md"
      "mkd"
      "nfo"
      "pod"
      "rst"
      "tex"
      "textfile"
      "txt"))
    (dired-rainbow-define
     database "#6574cd"
     ("xlsx" "xls" "csv" "accdb" "db" "mdb" "sqlite" "nc"))
    (dired-rainbow-define
     media "#de751f"
     ("mp3"
      "mp4"
      "MP3"
      "MP4"
      "avi"
      "mpeg"
      "mpg"
      "flv"
      "ogg"
      "mov"
      "mid"
      "midi"
      "wav"
      "aiff"
      "flac"))
    (dired-rainbow-define
     image "#f66d9b"
     ("tiff"
      "tif"
      "cdr"
      "gif"
      "ico"
      "jpeg"
      "jpg"
      "png"
      "psd"
      "eps"
      "svg"))
    (dired-rainbow-define log "#c17d11" ("log"))
    (dired-rainbow-define
     shell "#f6993f" ("awk" "bash" "bat" "sed" "sh" "zsh" "vim"))
    (dired-rainbow-define
     interpreted "#38c172"
     ("py"
      "ipynb"
      "rb"
      "pl"
      "t"
      "msql"
      "mysql"
      "pgsql"
      "sql"
      "r"
      "clj"
      "cljs"
      "scala"
      "js"))
    (dired-rainbow-define
     compiled "#4dc0b5"
     ("asm"
      "cl"
      "lisp"
      "el"
      "c"
      "h"
      "c++"
      "h++"
      "hpp"
      "hxx"
      "m"
      "cc"
      "cs"
      "cp"
      "cpp"
      "go"
      "f"
      "for"
      "ftn"
      "f90"
      "f95"
      "f03"
      "f08"
      "s"
      "rs"
      "hi"
      "hs"
      "pyc"
      ".java"))
    (dired-rainbow-define executable "#8cc4ff" ("exe" "msi"))
    (dired-rainbow-define
     compressed "#51d88a"
     ("7z"
      "zip"
      "bz2"
      "tgz"
      "txz"
      "gz"
      "xz"
      "z"
      "Z"
      "jar"
      "war"
      "ear"
      "rar"
      "sar"
      "xpi"
      "apk"
      "xz"
      "tar"))
    (dired-rainbow-define
     packaged "#faad63"
     ("deb"
      "rpm"
      "apk"
      "jad"
      "jar"
      "cab"
      "pak"
      "pk3"
      "vdf"
      "vpk"
      "bsp"))
    (dired-rainbow-define
     encrypted "#ffed4a"
     ("gpg" "pgp" "asc" "bfe" "enc" "signature" "sig" "p12" "pem"))
    (dired-rainbow-define
     fonts "#6cb2eb" ("afm" "fon" "fnt" "pfb" "pfm" "ttf" "otf"))
    (dired-rainbow-define
     partition "#e3342f"
     ("dmg" "iso" "bin" "nrg" "qcow" "toast" "vcd" "vmdk" "bak"))
    (dired-rainbow-define
     vc "#0074d9"
     ("git" "gitignore" "gitattributes" "gitmodules"))
    (dired-rainbow-define-chmod executable-unix "#38c172" "-.*x.*")))

;; 图标
(use-package nerd-icons)

;; 状态栏美化(终端兼容)
(use-package powerline
  :config (powerline-default-theme))

;; 快捷键提示
(use-package which-key
  :hook (after-init . which-key-mode)
  :custom (which-key-idle-delay 0.7))

;; 历史记录
(use-package savehist
  :hook (after-init . savehist-mode)
  :custom
  ;; 设置保存文件的位置
  (savehist-file (locate-user-emacs-file "cache/savehist"))
  ;; 额外保存剪切板和shell命令行历史
  (savehist-additional-variables '(kill-ring shell-command-history))
  ;; 不保存消息历史
  (savehist-ignored-variables '(message-history))
  ;; 自动去重
  (history-delete-duplicates t)
  ;; 保存历史数据条目
  (history-length 1000))

(use-package recentf
  :hook (after-init . recentf-mode)
  :custom
  (recentf-max-menu-item 10)
  (recentf-save-file (locate-user-emacs-file "cache/recentf")))

;; 语法高亮增强
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package highlight-parentheses
  :hook (minibuffer-setup . highlight-parentheses-minibuffer-setup))

(use-package hl-block-mode
  :hook (prog-mode . hl-block-mode))

(use-package hl-indent-scope
  :hook (prog-mode . hl-indent-scope-mode))

(use-package diff-hl
  :custom
  (diff-hl-side 'left)
  (diff-hl-margin-symbols-alist
   '((insert . "+")
     (delete . "-")
     (change . "~")
     (unknown . "?")
     (ignored . " ")
     (reference . " ")))
  :custom-face
  (diff-hl-insert
   ((t (:inherit success :weight bold :inverse-video t))))
  (diff-hl-delete
   ((t (:inherit error :weight bold :inverse-video t))))
  (diff-hl-change
   ((t (:inherit warning :weight bold :inverse-video t))))
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  (diff-hl-margin-mode 1)
  (with-eval-after-load 'magit
    (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)))

;; 搜索功能增强
(use-package vertico
  :init (vertico-mode)
  :bind
  (:map
   vertico-map
   ("DEL" . vertico-directory-delete-char)
   ("C-d" . vertico-directory-delete-word)))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion))
     (command (styles orderless))
     (symbol (styles orderless))
     (variable (styles orderless))))
  (completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t))

(use-package marginalia
  :init (marginalia-mode))

(use-package ripgrep)

(use-package consult
  :after ripgrep
  :bind
  (("C-s" . consult-line)
   ("C-x b" . consult-buffer)
   ("C-c v" . consult-bookmark)
   ("C-c s" . consult-buffer)
   ("C-c V" . consult-recent-file)
   ("C-x C-SPC" . consult-mark)
   ("C-x C-@" . consult-mark) ; macOS 映射
   ("C-c i" . consult-imenu)
   ("C-c g" . consult-grep)
   ("C-c G" . consult-ripgrep)))

;; 自动补全
(use-package company
  :hook (after-init . global-company-mode))

(use-package company-auctex
  :after auctex
  :hook (LaTeX-mode . company-auctex-init))

(use-package company-math
  :disabled
  :after company
  :init
  (add-to-list 'company-backends 'company-math-symbols-unicode)
  (add-to-list 'company-backends 'company-math-symbols-latex))

;; 大文件
(use-package vlf
  :config
  (require 'vlf-setup)
  (setq vlf-application 'dont-ask)
  (setq vlf-tune-enabled t))

;; Embark：上下文操作
(use-package embark
  :bind (("C-." . embark-act) ("C-;" . embark-dwim))
  :init (setq embark-prompter 'embark-completing-read-prompter))

;; Embark 与 Consult 的集成增强
(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . embark-consult-preview-minor-mode))

(use-package ace-window
  :bind (("C-x o" . 'ace-window)))

;; undo
(use-package undo-tree
  :init (global-undo-tree-mode)
  :custom (undo-tree-auto-save-history nil))

(use-package vundo)

;; avy
(use-package avy
  :bind (("C-c C-SPC" . avy-goto-char-timer)))

;; 文件树 (类似 VSCode 的 sidebar)
(use-package neotree
  :bind ("<f8>" . neotree-toggle))

;; 输入法
(use-package pyim
  :commands (pyim-mode toggle-input-method)
  :config
  (setq default-input-method "pyim")
  (setq pyim-page-length 9)
  (setq pyim-default-scheme 'quanpin)
  (setq-default pyim-punctuation-translate-p '(no)))

(use-package pyim-basedict
  :config (pyim-basedict-enable))

(use-package pyim-cangjiedict
  :config (pyim-cangjie6dict-enable))

;; 各种语言和文件格式的简单支持
(setopt elisp-fontify-semantically t)
(setopt treesit-font-lock-level 4)

(use-package treesit-auto
  :custom (treesit-auto-install 'nil)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package lisp-semantic-hl
  :hook ((emacs-lisp-mode lisp-mode) . lisp-semantic-hl-mode))

(use-package markdown-mode)

(use-package yaml-mode)

(use-package qml-mode)

(use-package kdl-mode)

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package lisp-mode
  :mode ("\\.lisp\\'" "\\.asd\\'"))

(use-package nix-ts-mode
  :commands nix-ts-mode)

(use-package haskell-ts-mode
  :commands haskell-ts-mode
  :custom (haskell-ts-font-lock-level 4))

(use-package eglot
  :hook (haskell-ts-mode . eglot-ensure))

(use-package dockerfile-mode
  :mode ("Dockerfile\\'" . dockerfile-mode)
  :config (put 'dockerfile-image-name 'safe-local-variable #'stringp))

(use-package dotenv-mode
  :mode ("\\.env\\..*\\'" . dotenv-mode))

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config (pdf-tools-install :no-query)
  :hook
  (pdf-view-mode . (lambda () (display-line-numbers-mode -1)))
  (pdf-view-mode . pdf-view-themed-minor-mode))

;; 键位设置和快捷键
(setq x-super-keysym 'hyper) ;通过把 Super 映射为 Hyper 在逻辑上禁用 Super 键

(provide 'emarccs-basic)

;;; emarccs-basic.el ends here

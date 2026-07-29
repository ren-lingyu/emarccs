;;; emarccs-shared-tex.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(use-package auctex
  :defer t
  :init
  (add-hook 'TeX-mode-hook #'TeX-fold-mode)
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (setq TeX-electric-escape nil
                    TeX-electric-sub-and-superscript nil)))
  :config
  (setq TeX-auto-local (locate-user-emacs-file "cache/auctex-auto/"))
  (unless (file-exists-p TeX-auto-local)
    (make-directory TeX-auto-local t))
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq TeX-parse-self t); 自动解析文档结构
  (setq TeX-master nil) ; 不指定主文件
  (setq preview-image-type nil) ; 禁用预览
  ;; (setq TeX-command-default "LuaLaTeX")
  (setq TeX-save-query nil)
  (setq TeX-show-compilation nil) ; 禁用编译
  (setq TeX-PDF-mode nil)
  (setq TeX-view-program-selection '((output-pdf "Zathura")))
  (setq TeX-view-program-list '(("Zathura" "zathura %o"))))

(use-package flycheck
  :hook (LaTeX-mode . flycheck-mode))

(use-package cdlatex
  :hook
  (org-mode . turn-on-org-cdlatex)
  (LaTeX-mode . company-auctex-init))

;; 启用 org-mode 的 LaTeX 区域高亮支持
(setq org-highlight-latex-and-related '(native script))

;; 自定义 LaTeX 高亮规则
(defun emarccs-shared-tex--org-latex-font-lock ()
  "Strict LaTeX syntax highlighting in org-mode."
  (font-lock-add-keywords
   nil
   '(;; 数学区域 $...$ 和 \( ... \)
     ("\\$[^$ \n]+\\$" . font-lock-constant-face)
     ("\\\\(\\([^() \n]+\\)\\\\)" 1 font-lock-constant-face)
     ;; 环境名, 如 \begin{equation}
     ("\\\\\\(begin\\|end\\){\\([^}]+\\)}"
      (1 font-lock-keyword-face)
      (2 font-lock-type-face)
      )
     ;; LaTeX 命令, 如 \frac, \alpha
     ("\\\\[a-zA-Z@]+" . font-lock-keyword-face)
     ;; 匹配 ^{...} 或 ^单个字符
     ("\\^\\({[^}]*}\\|[^{ \n]\\)" . font-lock-builtin-face)
     ;; 匹配 _{...} 或 _单个字符
     ("_\\({[^}]*}\\|[^{ \n]\\)" . font-lock-builtin-face)

     ;; 自定义宏命令(严格匹配)
     ("\\\\\\(mr\\|bs\\|diagmat\\){[^{} \n]+}" . font-lock-builtin-face)
     ;; \ab(...)、\ab{...}、\ab[...]、\ab|...|、\ab<...>
     ("\\\\ab(\\([^() \n]+\\))" 1 font-lock-builtin-face)
     ("\\\\ab{\\([^{} \n]+\\)}" 1 font-lock-builtin-face)
     ("\\\\ab\\[\\([^][]+\\)\\]" 1 font-lock-builtin-face)
     ("\\\\ab|\\([^| \n]+\\)|" 1 font-lock-builtin-face)
     ("\\\\ab<\\([^<> \n]+\\)>" 1 font-lock-builtin-face)
     ;; 量子态符号(严格匹配, 避免孤立符号)
     ("\\\\bra<\\([^| \n]+\\)|" 1 font-lock-keyword-face)
     ("\\\\ket|\\([^> \n]+\\)>" 1 font-lock-keyword-face)
     ;; \braket<...|...> 和 \braket<...|...|...>
     ("\\\\braket<\\([^| \n]+\\)|\\([^> \n]+\\)>" . font-lock-keyword-face)
     ("\\\\braket<\\([^| \n]+\\)|\\([^| \n]+\\)|\\([^> \n]+\\)>" . font-lock-keyword-face))))

;; (add-hook 'org-mode-hook #'emarccs-shared-tex--org-latex-font-lock)
(add-hook 'LaTeX-mode-hook #'emarccs-shared-tex--org-latex-font-lock)

;; 与latex环境有关的快捷键

(global-set-key
 (kbd "C-c l e e")
 (lambda ()
   (interactive)
   (insert "\\begin{equation}\n\n\\end{equation}")
   (forward-line -2)))

(global-set-key
 (kbd "C-c l e a")
 (lambda ()
   (interactive)
   (insert "\\begin{align}\n\n\\end{align}")
   (forward-line -2)))

(global-set-key
 (kbd "C-c l e s")
 (lambda ()
   (interactive)
   (insert "\\begin{split}\n\n\\end{split}")
   (forward-line -2)))

(global-set-key
 (kbd "C-c l e l")
 (lambda ()
   (interactive)
   (insert "\\label{}\n")
   (forward-line -1)))

(with-eval-after-load 'ox-latex
  (setq org-latex-precompile nil)
  (setq org-latex-compiler "lualatex")
  (setq org-latex-bib-compiler "biblatex")
  (setq org-latex-pdf-process
        (list "latexmk -f -pdf -%latex -interaction=nonstopmode -output-directory=$(realpath %o) $(realpath %f)"))
  (setq org-latex-precompile-compiler-map
        `(("pdflatex" . "latex")
          ("xelatex" . "xelatex -no-pdf")
          ("lualatex" . "dvilualatex" )))
  (setq org-latex-classes
        `(("article"
           ,(mapconcat #'identity
                       '("\\documentclass[10pt]{article}")
                       "\n")
           ("\\section{%s}" . "\\section*{%s}")
           ("\\subsection{%s}" . "\\subsection*{%s}")
           ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
           ("\\subsubsubsection{%s}" . "\\subsubsubsection*{%s}")
           ("\\paragraph{%s}" . "\\paragraph*{%s}")
           ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
          ("book"
           ,(mapconcat #'identity
                       '("\\documentclass[10pt]{book}")
                       "\n")
           ("\\chapter{%s}" . "\\chapter*{%s}")
           ("\\section{%s}" . "\\section*{%s}")
           ("\\subsection{%s}" . "\\subsection*{%s}")
           ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
           ("\\subsubsubsection{%s}" . "\\subsubsubsection*{%s}")
           ("\\paragraph{%s}" . "\\paragraph*{%s}")
           ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
          ("note"
           ,(mapconcat #'identity
                       '("\\documentclass[10pt,a4paper]{article}"
                         "\\usepackage{org-note}")
                       "\n")
           ("\\section{%s}" . "\\section*{%s}")
           ("\\subsection{%s}" . "\\subsection*{%s}")
           ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
           ("\\subsubsubsection{%s}" . "\\subsubsubsection*{%s}")
           ("\\paragraph{%s}" . "\\paragraph*{%s}")
           ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
          ("beamer"
           ,(mapconcat #'identity
                       '("\\documentclass[8pt]{beamer}"
                         "\\usepackage{org-beamer}")
                       "\n")
           ("\\section{%s}" . "\\section*{%s}")
           ("\\subsection{%s}" . "\\subsection*{%s}")
           ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
           ("\\subsubsubsection{%s}" . "\\subsubsubsection*{%s}")
           ("\\paragraph{%s}" . "\\paragraph*{%s}")
           ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))
  (setq org-export-headline-levels 4)
  (setq org-latex-default-class "note")
  ;; (setq org-latex-title-command "")
  (setq org-export-with-toc t)
  (defun emarccs-shared-tex--insert-toc-after-abstract-or-title (output backend info)
    (when (and (org-export-derived-backend-p backend 'latex)
               (string-match-p "\\\\documentclass[[:space:]]*\\(?:\\[.*?\\][[:space:]]*\\)?{[[:space:]]*article[[:space:]]*}" output))
      (if (string-match "\\\\end{abstract}" output)
          ;; 如果有 abstract 块, 在 \end{abstract} 后插入目录
          (progn (setq output
                       (replace-regexp-in-string "\\\\tableofcontents"
                                                 ""
                                                 output))
                 (setq output
                       (replace-regexp-in-string "\\\\end{abstract}"
                                                 "\\\\end{abstract}\n\n\\\\tableofcontents\n"
                                                 output))
                 )
        ;; 如果没有 abstract 块, 在 \maketitle 后插入目录
        (progn (setq output
                     (replace-regexp-in-string "\\\\tableofcontents"
                                               ""
                                               output))
               (setq output
                     (replace-regexp-in-string "\\\\maketitle"
                                               "\\\\maketitle\n\\\\tableofcontents\n"
                                               output))))
      (setq output
            (replace-regexp-in-string
             "\\\\end{abstract}[[:space:]]*\\\\tableofcontents[[:space:]]*\\\\begin{abstract}"
             "\\\\end{abstract}\n\n\\\\begin{abstract}"
             output)))
    output)
  (add-hook 'org-export-filter-final-output-functions
            #'emarccs-shared-tex--insert-toc-after-abstract-or-title)
  (defun emarccs-shared-tex--remove-angle-brackets-in-timestamp (output backend info)
    (when (org-export-derived-backend-p backend 'latex)
      (setq output
            (replace-regexp-in-string
             "\\(\\\\date{.*?\\)<\\([^>]+\\)>\\(.*?}\\)"
             "\\1\\2\\3"
             output)))
    output)
  (add-hook 'org-export-filter-final-output-functions
            #'emarccs-shared-tex--remove-angle-brackets-in-timestamp)
  ;; 定义\label{eq:...}和\eqref{eq:...}对应的链接类型
  (org-link-set-parameters "eq"
                           :follow
                           (lambda (path arg)
                             (let ((label (concat "\\label{eq:" path "}")))
                               (org-mark-ring-push)
                               (goto-char (point-min))
                               (if (re-search-forward label nil t)
                                   (progn
                                     (beginning-of-line)
                                     (recenter)
                                     (message "找到公式引用: %s" label))
                                 (message "未找到公式引用: %s" label))))
                           ;; 设置导出函数，导出为 \eqref{eq:...}
                           :export
                           (lambda (path description backend info)
                             (cond
                              ((or (eq backend 'latex) (eq backend 'beamer))
                               (format "\\eqref{eq:%s}" path))
                              ((eq backend 'html)
                               (format "<span class=\"eqref\">eq:%s</span>"
                                       (or description path)))
                              (t (or description (format "eq:%s" path)))))
                           :face
                           '(;; :inherit 'org-link
                             :foreground "dark red"
                             :background "yellow"
                             :underline t)
                           :help-echo
                           "公式引用链接. \n格式: [[eq:<label>]]. \n跳转时采用正则表达式查找当前光标所在buffer内\\label{eq:<label>}所在行. "))

(with-eval-after-load 'ox-beamer
  (setq org-beamer-frame-level 3)
  (setq org-beamer-theme nil)
  (setq org-beamer-outline-frame-title "Outlines")
  (setq org-beamer-outline-frame-options "t"))

;; The End
(provide 'emarccs-shared-tex)

;;; emarccs-shared-tex.el ends here

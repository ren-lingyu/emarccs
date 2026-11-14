;;; emarccs-tex.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(eval-when-compile
  (require 'use-package))

(use-package auctex
  :defer t
  :init
  (add-hook 'TeX-mode-hook #'TeX-fold-mode)
  (add-hook
   'LaTeX-mode-hook
   (lambda ()
     (setq
      TeX-electric-escape nil
      TeX-electric-sub-and-superscript nil)))
  :config
  (setq TeX-auto-local (locate-user-emacs-file "cache/auctex-auto/"))
  (unless (file-exists-p TeX-auto-local)
    (make-directory TeX-auto-local t))
  (setq TeX-auto-save t)
  (setq TeX-parse-self t) ; 自动解析文档结构
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
  (setq
   org-latex-pdf-process
   (list
    "latexmk -f -pdf -%latex -interaction=nonstopmode -output-directory=$(realpath %o) $(realpath %f)"))
  (setq org-latex-precompile-compiler-map
        `(("pdflatex" . "latex")
          ("xelatex" . "xelatex -no-pdf")
          ("lualatex" . "dvilualatex")))
  (setq org-latex-classes
        `(("article"
           ,(mapconcat #'identity '("\\documentclass[10pt]{article}")
                       "\n")
           ("\\section{%s}" . "\\section*{%s}")
           ("\\subsection{%s}" . "\\subsection*{%s}")
           ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
           ("\\subsubsubsection{%s}" . "\\subsubsubsection*{%s}")
           ("\\paragraph{%s}" . "\\paragraph*{%s}")
           ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
          ("book"
           ,(mapconcat #'identity '("\\documentclass[10pt]{book}")
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
  (defun emarccs-tex--insert-toc-after-abstract-or-title
      (output backend _info)
    (when
        (and
         (org-export-derived-backend-p backend 'latex)
         (string-match-p
          "\\\\documentclass[[:space:]]*\\(?:\\[.*?\\][[:space:]]*\\)?{[[:space:]]*article[[:space:]]*}"
          output))
      (if (string-match "\\\\end{abstract}" output)
          ;; 如果有 abstract 块, 在 \end{abstract} 后插入目录
          (progn
            (setq output
                  (replace-regexp-in-string
                   "\\\\tableofcontents" "" output))
            (setq output
                  (replace-regexp-in-string
                   "\\\\end{abstract}"
                   "\\\\end{abstract}\n\n\\\\tableofcontents\n"
                   output)))
        ;; 如果没有 abstract 块, 在 \maketitle 后插入目录
        (progn
          (setq output
                (replace-regexp-in-string
                 "\\\\tableofcontents" "" output))
          (setq output
                (replace-regexp-in-string
                 "\\\\maketitle"
                 "\\\\maketitle\n\\\\tableofcontents\n"
                 output))))
      (setq
       output
       (replace-regexp-in-string
        "\\\\end{abstract}[[:space:]]*\\\\tableofcontents[[:space:]]*\\\\begin{abstract}"
        "\\\\end{abstract}\n\n\\\\begin{abstract}"
        output)))
    output)
  (defun emarccs-tex--remove-angle-brackets-in-timestamp
      (output backend info)
    (when (org-export-derived-backend-p backend 'latex)
      (setq output
            (replace-regexp-in-string
             "\\(\\\\date{.*?\\)<\\([^>]+\\)>\\(.*?}\\)"
             "\\1\\2\\3"
             output)))
    output)
  (defun emarccs-tex--register-latex-output-filters (info backend)
    (when (org-export-derived-backend-p backend 'latex)
      (setq info
            (plist-put
             info
             :filter-final-output
             (append
              (plist-get info :filter-final-output)
              '(emarccs-tex--remove-angle-brackets-in-timestamp
                emarccs-tex--insert-toc-after-abstract-or-title)))))
    info)
  (add-hook
   'org-export-filter-options-functions
   #'emarccs-tex--register-latex-output-filters))

(defvar org-beamer-frame-level)
(defvar org-beamer-theme)
(defvar org-beamer-outline-frame-title)
(defvar org-beamer-outline-frame-options)
(with-eval-after-load 'ox-beamer
  (setq org-beamer-frame-level 3)
  (setq org-beamer-theme nil)
  (setq org-beamer-outline-frame-title "Outlines")
  (setq org-beamer-outline-frame-options "t"))

;; The End
(provide 'emarccs-tex)

;;; emarccs-tex.el ends here

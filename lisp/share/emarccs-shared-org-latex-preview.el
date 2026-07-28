;;; emarccs-shared-org-latex-preview.el --- Org preview configuration -*- lexical-binding: t; -*-
;;; commentary:

;;; from https://abode.karthinks.com/org-latex-preview/

;;; code:

(defconst texlive (expand-file-name "./config/texlive.sh" org-directory))

;; 预览
(with-eval-after-load 'org-latex-preview
  (plist-put org-latex-preview-appearance-options
             :page-width 0.8)
  (setq org-latex-preview-process-default 'dvisvgm)
  ;; (add-hook 'org-mode-hook 'org-latex-preview-mode)
  (setq org-latex-preview-mode-ignored-commands
        '(next-line previous-line mwheel-scroll
                    scroll-up-command scroll-down-command))
  (setq org-latex-preview-numbered t)
  (setq org-latex-preview-mode-display-live nil)
  (setq org-latex-preview-mode-update-delay 1)
  (setq org-latex-preview-mode-track-inserts nil)
  (setq org-startup-with-latex-preview nil)
  (setq org-latex-preview-mode-ignored-environments nil)
  (setq org-latex-preview-process-precompile nil) ; lualatex does not support precompile
  (setq org-latex-preview-mode nil)
  (setq org-latex-preview-preamble
        (concat
         "\\documentclass{article}\n"
         "\\usepackage{xcolor}\n"
         "[PACKAGES]\n"
         "\\usepackage{org-preview}\n"
         "\\pagestyle{empty}\n"))
  (setq org-latex-preview-compiler-command-map
        `(("pdflatex" . "latexmk -norc -latex=pdflatex")
          ("xelatex" . "latexmk -norc -xelatex -no-pdf")
          ("lualatex" . "latexmk -norc -dvilua")))
  (setq org-latex-preview-process-default 'dvisvgm)
  (setq org-latex-preview-process-alist
        `((dvisvgm :programs ("dvisvgm" "latexmk")
                   :description "dvi > svg"
                   :message "you need to install the programs: texlive and dvisvgm."
                   :image-input-type "dvi"
                   :image-output-type "svg"
                   :latex-compiler ("%l -interaction=nonstopmode -outdir=%o %f")
                   :image-converter ("dvisvgm --page=1- --optimize --clipjoin --relative --no-fonts --bbox=preview -o %B-%%9p.svg %f"))
          (docker :programs ("docker")
                  :description "dvi > svg"
                  :message "you need to install the programs: texlive and dvisvgm in docker image."
                  :image-input-type "dvi"
                  :image-output-type "svg"
                  :latex-compiler (,(format "%s %%l -interaction=nonstopmode -outdir=%%o %%f" (shell-quote-argument texlive)))
                  :image-converter
                  (,(format "%s dvisvgm --page=1- --optimize --clipjoin --relative --no-fonts --bbox=preview -o %%B-%%%%9p.svg %%f" (shell-quote-argument texlive)))))))

(provide 'emarccs-shared-org-latex-preview)
;;; emarccs-shared-org-latex-preview.el ends here.

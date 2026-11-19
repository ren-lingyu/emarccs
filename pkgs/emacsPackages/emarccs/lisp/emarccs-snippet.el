
;;; emarccs-snippet.el --- Snippet configuration -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(eval-when-compile
  (require 'use-package))

(use-package yasnippet
  :hook
  (LaTeX-mode . yas-minor-mode)
  (org-mode . yas-minor-mode))

(use-package aas
  :hook
  (LaTeX-mode . aas-activate-for-major-mode)
  (org-mode . aas-activate-for-major-mode)
  :config
  (defun emarccs-snippet--org-block-snippet
      (name &optional parameters)
    "Return an AAS expansion for an Org block named NAME.
PARAMETERS, when non-nil, is the literal text after the opening name.
Edit the opening name to update its closing mirror, then jump to the body."
    (list
     'yas
     (format "#+begin_${1:%s}%s\n$0\n#+end_$1\n"
             name
             (if parameters
                 (concat " " parameters)
               ""))))

  (remhash 'text-mode aas-keymaps)
  (aas-set-snippets
   'text-mode
   ;; Expand unconditionally.
   ";o-" "ō" ";i-" "ī" ";a-" "ā" ";u-" "ū" ";e-" "ē")
  (remhash 'org-mode aas-keymaps)
  (aas-set-snippets
   'org-mode
   ";par"
   '(yas "($0)")
   ";stm"
   '(yas "\\\\(($0)\\\\)")
   ;; General Org blocks.
   ";;block"
   (emarccs-snippet--org-block-snippet "block")
   ";;abst"
   (emarccs-snippet--org-block-snippet "abstract")
   ";;comm"
   (emarccs-snippet--org-block-snippet "comment")
   ";;quote"
   (emarccs-snippet--org-block-snippet "quote")
   ";;center"
   (emarccs-snippet--org-block-snippet "center")
   ";;example"
   (emarccs-snippet--org-block-snippet "example")
   ";;tm"
   (emarccs-snippet--org-block-snippet "texmacs")
   ";;eq"
   (emarccs-snippet--org-block-snippet "equation")
   ";;fig"
   (emarccs-snippet--org-block-snippet "figure")
   ";;tab"
   (emarccs-snippet--org-block-snippet "table")
   ;; Formal statements use the Org TeXmacs canonical wrapper.
   ";;thm"
   (emarccs-snippet--org-block-snippet "statement" "theorem")
   ";;prop"
   (emarccs-snippet--org-block-snippet "statement" "proposition")
   ";;lem"
   (emarccs-snippet--org-block-snippet "statement" "lemma")
   ";;cor"
   (emarccs-snippet--org-block-snippet "statement" "corollary")
   ";;axm"
   (emarccs-snippet--org-block-snippet "statement" "axiom")
   ";;def"
   (emarccs-snippet--org-block-snippet "statement" "definition")
   ";;notn"
   (emarccs-snippet--org-block-snippet "statement" "notation")
   ";;conj"
   (emarccs-snippet--org-block-snippet "statement" "conjecture")
   ";;rem"
   (emarccs-snippet--org-block-snippet "statement" "remark")
   ";;exmp"
   (emarccs-snippet--org-block-snippet "statement" "example")
   ";;note"
   (emarccs-snippet--org-block-snippet "statement" "note")
   ";;warn"
   (emarccs-snippet--org-block-snippet "statement" "warning")
   ";;conv"
   (emarccs-snippet--org-block-snippet "statement" "convention")
   ";;exer"
   (emarccs-snippet--org-block-snippet "statement" "exercise")
   ";;prob"
   (emarccs-snippet--org-block-snippet "statement" "problem")
   ";;prf"
   (emarccs-snippet--org-block-snippet "statement" "proof")
   ;; LaTeX fragments and environments.
   ";eq"
   (lambda ()
     (interactive)
     (insert "\\(  \\)")
     (forward-char -3))
   ";ee"
   (lambda ()
     (interactive)
     (insert "\\begin{equation}\n\n\\end{equation}\n")
     (forward-line -2))
   ";ean"
   (lambda ()
     (interactive)
     (insert "\\begin{align}\n\n\\end{align}\n")
     (forward-line -2))
   ";ead"
   (lambda ()
     (interactive)
     (insert "\\begin{aligned}[t]\n\n\\end{aligned}")
     (forward-line -1))
   ";es"
   (lambda ()
     (interactive)
     (insert "\\begin{split}\n\n\\end{split}")
     (forward-line -1))
   ";egd"
   (lambda ()
     (interactive)
     (insert "\\begin{gathered}\n\n\\end{gathered}")
     (forward-line -1))
   ";eyq"
   (lambda ()
     (interactive)
     (insert
      "\\begin{tikzpicture}\n\\begin{yquant}\n\n\\end{yquant}\n\\end{tikzpicture}")
     (forward-line -2))
   ";eyg"
   (lambda ()
     (interactive)
     (insert
      "\\begin{tikzpicture}\n\\begin{yquantgroup}\n\n\\end{yquantgroup}\n\\end{tikzpicture}")
     (forward-line -2))))

(use-package laas
  :no-require t
  :init
  (setq laas-basic-snippets nil)
  (setq laas-subscript-snippets nil)
  (setq laas-frac-snippet nil)
  (setq laas-accent-snippets nil)
  :config
  (aas-set-snippets
   'laas-mode
   ;; Labels.
   ";label"
   '(yas "\\label{$1:$2}\n$0")
   ;; Mathematical fonts.
   ";mrm"
   '(yas "\\mathrm{$1}")
   ";mcal"
   '(yas "\\mathcal{$1}")
   ";mscr"
   '(yas "\\mathscr{$1}")
   ";mbb"
   '(yas "\\mathbb{$1}")
   ";mtt"
   '(yas "\\mathtt{$1}")
   ";mfrak"
   '(yas "\\mathfrak{$1}")
   ;; Operators with limits.
   ";sum"
   '(yas "\\sum_{ $1 }^{ $2 } $0")
   ";int"
   '(yas "\\int_{ $1 }^{ $2 } $0")
   ";prod"
   '(yas "\\prod_{ $1 }^{ $2 } $0")
   ";otimes"
   '(yas "\\bigotimes_{ $1 }^{ $2 } $0")
   ;; Scalable delimiters.
   ";pp"
   '(yas "\\left( $1 \\right)$0")
   ";ss"
   '(yas "\\left[ $1 \\right]$0")
   ";bb"
   '(yas "\\left\\\\{ $1 \\right\\\\}$0")
   ";aa"
   '(yas "\\left\\langle $1 \\right\\rangle$0")
   ";vv"
   '(yas "\\left\\lvert $1 \\right\\rvert$0")
   ";VV"
   '(yas "\\left\\lVert $1 \\right\\rVert$0")
   ;; Physics2 delimiters.
   ";abpp"
   '(yas "\\ab( $1 )$0")
   ";abss"
   '(yas "\\ab[ $1 ]$0")
   ";abbb"
   '(yas "\\ab\\\\{ $1 \\\\}$0")
   ";abaa"
   '(yas "\\ab< $1 >$0")
   ";abvv"
   '(yas "\\ab| $1 |$0")
   ";abVV"
   '(yas "\\ab\\\\| $1 \\\\|$0")
   ;; Bra-ket notation.
   ";ket"
   '(yas "\\ket| $1 >$0")
   ";bra"
   '(yas "\\bra< $1 |$0")
   ";bk"
   '(yas "\\braket< $1 | $2 >$0")
   ";kb"
   '(yas "\\ketbra| $1 >< $2 |$0")
   ";bok"
   '(yas "\\braket< $1 | $3 | $2 >$0")
   ;; Other mathematical structures.
   ";eval"
   '(yas "\\eval{ $1 }_{ $2 }^{ $3 }$0")
   ";frac"
   '(yas "\\frac{ $1 }{ $2 }$0")
   ";sqrt"
   '(yas "\\sqrt{ $1 }$0")
   ";text"
   '(yas "\\text{$1}$0")
   ";tensor"
   '(yas "\\tensor{ $1 }{ $2 }$0")
   ";sp"
   '(yas "\\sp{ $1 }$0")
   ";sb"
   '(yas "\\sb{ $1 }$0"))
  :hook
  (LaTeX-mode . laas-mode)
  (org-mode . laas-mode))

(provide 'emarccs-snippet)

;;; emarccs-snippet.el ends here

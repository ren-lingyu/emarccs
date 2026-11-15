;;; snippets.el --- Test auto-activating snippets -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

;; Load the configuration before LAAS so that its default snippet variables
;; are disabled before LAAS registers its keymap.
(require 'emarccs-snippet)
(require 'aas)
(require 'laas)
(require 'yasnippet)
(require 'org)
(require 'scheme)

(defmacro emarccs-snippet-test--with-buffer (mode &rest body)
  "Run BODY in a fresh selected buffer with MODE and its real hooks."
  (declare (indent 1))
  `(save-window-excursion
     (with-temp-buffer
       (switch-to-buffer (current-buffer))
       (funcall ,mode)
       (should aas-mode)
       (should yas-minor-mode)
       ,@body)))

(ert-deftest emarccs-snippet-test--org-blocks ()
  "Every Org block trigger expands to its intended wrapper and body field."
  (dolist (spec
           '((";;block" "block")
             (";;abst" "abstract")
             (";;comm" "comment")
             (";;quote" "quote")
             (";;center" "center")
             (";;example" "example")
             (";;tm" "texmacs")
             (";;eq" "equation")
             (";;fig" "figure")
             (";;tab" "table")
             (";;thm" "statement" "theorem")
             (";;prop" "statement" "proposition")
             (";;lem" "statement" "lemma")
             (";;cor" "statement" "corollary")
             (";;axm" "statement" "axiom")
             (";;def" "statement" "definition")
             (";;notn" "statement" "notation")
             (";;conj" "statement" "conjecture")
             (";;rem" "statement" "remark")
             (";;exmp" "statement" "example")
             (";;note" "statement" "note")
             (";;warn" "statement" "warning")
             (";;conv" "statement" "convention")
             (";;exer" "statement" "exercise")
             (";;prob" "statement" "problem")
             (";;prf" "statement" "proof")))
    (pcase-let ((`(,trigger ,name . ,parameters) spec))
      (emarccs-snippet-test--with-buffer #'org-mode
        ;; Drive the actual AAS post-self-insert hook, not just the helper.
        (execute-kbd-macro trigger)
        (let ((opening
               (concat
                "#+begin_" name
                (if parameters
                    (concat " " (car parameters))
                  ""))))
          (should
           (equal
            (buffer-string) (concat opening "\n\n#+end_" name "\n")))
          (should (looking-at (regexp-quote name)))
          (execute-kbd-macro (kbd "TAB"))
          (should (= (point) (+ (point-min) (length opening) 1)))
          (execute-kbd-macro "Body")
          (should
           (equal
            (buffer-string)
            (concat opening "\nBody\n#+end_" name "\n"))))))))

(ert-deftest emarccs-snippet-test--block-name-mirror ()
  "Editing the opening name also edits the closing name before body input."
  (dolist (spec
           '((";;eq" . "equation*")
             (";;fig" . "figure*")
             (";;tab" . "table*")
             (";;block" . "custom")))
    (emarccs-snippet-test--with-buffer #'org-mode
      (execute-kbd-macro (car spec))
      ;; YAS replaces the default when typing into the untouched first field.
      (execute-kbd-macro (cdr spec))
      (execute-kbd-macro (kbd "TAB"))
      (should
       (equal
        (buffer-string)
        (format "#+begin_%s\n\n#+end_%s\n" (cdr spec) (cdr spec))))
      (should
       (= (point)
          (+ (point-min) (length "#+begin_") (length (cdr spec)) 1)))
      (execute-kbd-macro "Body")
      (should
       (equal
        (buffer-string)
        (format "#+begin_%s\nBody\n#+end_%s\n"
                (cdr spec)
                (cdr spec)))))))

(ert-deftest emarccs-snippet-test--parentheses ()
  "The generic S-expression snippet expands in Org buffers."
  (emarccs-snippet-test--with-buffer #'org-mode
    (execute-kbd-macro ";par")
    (should (equal (buffer-string) "()"))
    (should (= (point) (1+ (point-min))))
    (execute-kbd-macro "math")
    (should (equal (buffer-string) "(math)"))))

(ert-deftest emarccs-snippet-test--scheme-isolation ()
  "Scheme buffers do not enable or expand the configured snippets."
  (dolist (trigger '(";;eq" ";eq" ";frac" ";par"))
    (save-window-excursion
      (with-temp-buffer
        (switch-to-buffer (current-buffer))
        (scheme-mode)
        (should-not aas-mode)
        (should-not laas-mode)
        (should-not yas-minor-mode)
        (execute-kbd-macro trigger)
        (should (equal (buffer-string) trigger))))))

(ert-deftest emarccs-snippet-test--retained-latex ()
  "The original LaTeX triggers, including the suffix of ;;eq, still work."
  (emarccs-snippet-test--with-buffer #'org-mode
    (execute-kbd-macro ";eq")
    (should (equal (buffer-string) "\\(  \\)"))
    (should (= (point) (+ (point-min) 3))))
  (emarccs-snippet-test--with-buffer #'org-mode
    (execute-kbd-macro ";ee")
    (should
     (equal (buffer-string) "\\begin{equation}\n\n\\end{equation}\n"))
    (should (looking-at "\n\\\\end{equation}")))
  (emarccs-snippet-test--with-buffer #'org-mode
    (execute-kbd-macro ";frac")
    (execute-kbd-macro "a")
    (execute-kbd-macro (kbd "TAB"))
    (execute-kbd-macro "b")
    (execute-kbd-macro (kbd "TAB"))
    (should (equal (buffer-string) "\\frac{ a }{ b }"))
    (should (= (point) (point-max)))))

(ert-deftest emarccs-snippet-test--removed-symbols ()
  "Removed symbols do not expand, and upstream defaults remain disabled."
  (should-not laas-basic-snippets)
  (should-not laas-subscript-snippets)
  (should-not laas-frac-snippet)
  (should-not laas-accent-snippets)
  (dolist (trigger
           '(";;alp"
             ";;bet"
             ";;ale"
             ";uniti"
             ";hom"
             ";end"
             ";id"
             ";ker"
             ";im"
             ";tr"
             ";times"
             ";a"
             "!="))
    (emarccs-snippet-test--with-buffer #'org-mode
      (insert "\\( ")
      (execute-kbd-macro trigger)
      (should (equal (buffer-string) (concat "\\( " trigger))))))

(ert-deftest emarccs-snippet-test--retained-text ()
  "The existing long-vowel snippets remain available through text-mode."
  (dolist (spec
           '((";o-" . "ō")
             (";i-" . "ī")
             (";a-" . "ā")
             (";u-" . "ū")
             (";e-" . "ē")))
    (emarccs-snippet-test--with-buffer #'org-mode
      (execute-kbd-macro (car spec))
      (should (equal (buffer-string) (cdr spec))))))

;;; snippets.el ends here

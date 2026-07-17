;;; treesit-grammars-smoke.el -*- lexical-binding: t; -*-

(defun emarccs-treesit-grammars-smoke--check (condition message)
  (unless condition
    (error "%s" message)))

(require 'seq)
(require 'treesit)
(require 'treesit-auto)

(let* ((languages '(bash c cmake cpp css dockerfile html javascript json
                         markdown nix python rust toml tsx typescript yaml))
       (missing nil)
       (tsx-override '(tsx "libtree-sitter-tsx" "tree_sitter_typescript")))
  (emarccs-treesit-grammars-smoke--check
   (seq-some (lambda (path)
               (string-match-p "emacs-treesit-grammars" path))
             treesit-extra-load-path)
   "emacs-treesit-grammars is missing from treesit-extra-load-path")
  (emarccs-treesit-grammars-smoke--check
   (member tsx-override treesit-load-name-override-list)
   "tsx load name override is missing from treesit-load-name-override-list")
  (dolist (language languages)
    (unless (treesit-language-available-p language)
      (push language missing)))
  (when missing
    (error "Missing tree-sitter grammars: %S" (nreverse missing)))
  (princ (format "treesit-grammars-smoke ok: %d grammars\n"
                 (length languages))))

;;; treesit-grammars-smoke.el ends here

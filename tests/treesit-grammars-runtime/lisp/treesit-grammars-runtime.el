;;; treesit-grammars-runtime.el -*- lexical-binding: t; -*-

;;; This test checks every libtree-sitter-*.so linked by
;;; emacs-treesit-grammars.  It verifies Emacs native treesit runtime
;;; availability, not treesit-auto recipes, major-mode selection, font-lock,
;;; indentation, or real-source parsing behavior.

(require 'seq)
(require 'subr-x)
(require 'treesit)
(require 'treesit-auto)

(defun emarccs-treesit-grammars-runtime--grammar-dir ()
  (seq-find (lambda (path)
              (and (string-match-p "emacs-treesit-grammars" path)
                   (string-suffix-p "/lib" path)))
            treesit-extra-load-path))

(defun emarccs-treesit-grammars-runtime--language-from-library (file)
  (intern (string-remove-prefix "libtree-sitter-" (file-name-base file))))

(defun emarccs-treesit-grammars-runtime--candidate-init-symbols (file)
  (with-temp-buffer
    (set-buffer-multibyte nil)
    (insert-file-contents-literally file)
    (goto-char (point-min))
    (let (symbols)
      (while (re-search-forward "tree_sitter_[A-Za-z0-9_]+" nil t)
        (let ((symbol (match-string 0)))
          (unless (string-match-p "_external_scanner_" symbol)
            (push symbol symbols))))
      (sort (delete-dups symbols) #'string<))))

(defun emarccs-treesit-grammars-runtime--available-p (language)
  ;; This checks Emacs' runtime lookup path, library name inference, and
  ;; treesit-load-name-override-list entries.
  (condition-case err
      (if (treesit-language-available-p language)
          t
        (list 'missing))
    (error (list 'error err))))

(defun emarccs-treesit-grammars-runtime--parser-create (language)
  ;; This checks that the located grammar can initialize a real parser.
  (condition-case err
      (with-temp-buffer
        (insert "\n")
        (treesit-parser-create language)
        t)
    (error (list 'error err))))

(let* ((grammar-dir (emarccs-treesit-grammars-runtime--grammar-dir))
       (libraries
        (and grammar-dir
             (sort (directory-files grammar-dir t "\\`libtree-sitter-.*\\.so\\'")
                   #'string<)))
       (find-failures nil)
       (use-failures nil))
  (unless grammar-dir
    (error "emacs-treesit-grammars is missing from treesit-extra-load-path: %S"
           treesit-extra-load-path))
  ;; The test follows the actual Nix output, so with-all-grammars additions are
  ;; checked automatically without maintaining a second static grammar list.
  (dolist (library libraries)
    (let* ((language (emarccs-treesit-grammars-runtime--language-from-library library))
           (available (emarccs-treesit-grammars-runtime--available-p language)))
      (if (eq available t)
          (let ((created (emarccs-treesit-grammars-runtime--parser-create language)))
            (unless (eq created t)
              (push (list language
                          (file-name-nondirectory library)
                          created
                          (emarccs-treesit-grammars-runtime--candidate-init-symbols library))
                    use-failures)))
        (push (list language
                    (file-name-nondirectory library)
                    available
                    (emarccs-treesit-grammars-runtime--candidate-init-symbols library))
              find-failures))))
  (setq find-failures (nreverse find-failures)
        use-failures (nreverse use-failures))
  (when find-failures
    (princ (format "tree-sitter grammars Emacs could not find: %S\n"
                   find-failures)))
  (when use-failures
    (princ (format "tree-sitter grammars Emacs could not use: %S\n"
                   use-failures)))
  (when (or find-failures use-failures)
    (error "tree-sitter grammar runtime check failed: find=%d use=%d"
           (length find-failures)
           (length use-failures)))
  (princ (format "treesit-grammars-runtime ok: found and used %d grammars\n"
                 (length libraries))))

;;; treesit-grammars-runtime.el ends here

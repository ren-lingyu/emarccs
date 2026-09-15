;;; emarccs-shared--org-babellike-block.el --- Babel-like Org special blocks -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(require 'org)
(require 'org-element)
(require 'ob-core)
(require 'ox)

(declare-function org-latex--caption/label-string
                  "ox-latex"
                  (element info))
(declare-function org-latex--caption-above-p
                  "ox-latex"
                  (element info))

(defvar emarccs-shared--org-babellike-block-registry nil
  "Registry of Babel-like Org special blocks.

Each entry has the form

  (NAME . PARAMETERS)

where NAME is the special-block name as a string and PARAMETERS
is a list of allowed keyword parameters.

For example:

  ((\"reply\" . (:from :subject :date)))

Parameter syntax follows Babel header-argument syntax.  Parameter
values are uniformly interpreted as headline-style Org secondary
strings.")

(defconst emarccs-shared--org-babellike-block--secondary-string-restriction
  (org-element-restriction 'headline)
  "Restriction used to parse block parameter values.")

(defconst emarccs-shared--org-babellike-block--backend-registry
  '((latex
     :feature ox-latex
     :transcoder org-latex-special-block
     :advice emarccs-shared--org-babellike-block--latex
     :renderer emarccs-shared--org-babellike-block--render-latex)
    (html
     :feature ox-html
     :transcoder org-html-special-block
     :advice emarccs-shared--org-babellike-block--html
     :renderer emarccs-shared--org-babellike-block--render-html))
  "Backend definitions for Babel-like Org special blocks.")

(defun emarccs-shared--org-babellike-block--spec (block)
  "Return the registry entry corresponding to BLOCK."
  (assoc-string
   (org-element-property :type block)
   emarccs-shared--org-babellike-block-registry
   t))

(defun emarccs-shared--org-babellike-block--backend-spec (backend)
  "Return the backend specification corresponding to BACKEND."
  (cdr
   (assq
    backend
    emarccs-shared--org-babellike-block--backend-registry)))

(defun emarccs-shared--org-babellike-block--parse-parameters
    (block spec)
  "Parse and validate parameters of BLOCK according to SPEC."
  (let ((allowed (cdr spec))
        (parameters
         (org-babel-parse-header-arguments
          (or (org-element-property :parameters block) "")
          t))
        seen)
    (dolist (parameter parameters)
      (let ((key (car parameter))
            (value (cdr parameter)))
        (unless (memq key allowed)
          (user-error
           "Unknown %s parameter: %s"
           (org-element-property :type block)
           key))
        (unless value
          (user-error
           "%s parameter %s requires a value"
           (org-element-property :type block)
           key))
        (when (memq key seen)
          (user-error
           "Duplicate %s parameter: %s"
           (org-element-property :type block)
           key))
        (push key seen)))

    ;; Babel may parse some literal values into non-string Lisp
    ;; objects.  Semantically, every block parameter is an Org
    ;; secondary string.
    (mapcar
     (lambda (parameter)
       (cons
        (car parameter)
        (if (stringp (cdr parameter))
            (cdr parameter)
          (format "%s" (cdr parameter)))))
     parameters)))

(defun emarccs-shared--org-babellike-block--export-secondary-string
    (string block info)
  "Export STRING as an Org secondary string.

BLOCK is used as the parent syntax node.  INFO is the current
export environment."
  (org-export-data
   (org-element-parse-secondary-string
    string
    emarccs-shared--org-babellike-block--secondary-string-restriction
    block)
   info))

(defun emarccs-shared--org-babellike-block--export-parameters
    (block spec info)
  "Export parameters of BLOCK according to SPEC and INFO."
  (mapcar
   (lambda (parameter)
     (cons
      (car parameter)
      (emarccs-shared--org-babellike-block--export-secondary-string
       (cdr parameter)
       block
       info)))
   (emarccs-shared--org-babellike-block--parse-parameters
    block
    spec)))

(defun emarccs-shared--org-babellike-block--export
    (backend original block contents info)
  "Export registered BLOCK through BACKEND.

ORIGINAL is the backend's original special-block transcoder."
  (let ((spec
         (emarccs-shared--org-babellike-block--spec block)))
    (if (not spec)
        (funcall original block contents info)

      (let* ((backend-spec
              (emarccs-shared--org-babellike-block--backend-spec
               backend))
             (renderer
              (plist-get backend-spec :renderer)))
        (unless backend-spec
          (user-error
           "Unknown Babel-like block backend: %s"
           backend))
        (unless renderer
          (user-error
           "No Babel-like block renderer registered for backend %s"
           backend))

        (funcall
         renderer
         original
         block
         contents
         (emarccs-shared--org-babellike-block--export-parameters
          block
          spec
          info)
         info)))))

;;; LaTeX backend

(defun emarccs-shared--org-babellike-block--render-latex
    (original block contents parameters info)
  "Render registered BLOCK for the LaTeX backend."
  ;; With no Babel-like parameters, preserve the ordinary
  ;; `org-latex-special-block' behavior completely.
  (if (not parameters)
      (funcall original block contents info)

    (when (org-export-read-attribute
           :attr_latex block :options)
      (user-error
       "%s cannot use both block parameters and ATTR_LATEX :options"
       (org-element-property :type block)))

    (let* ((type
            (org-element-property :type block))
           (options
            (concat
             "["
             (mapconcat
              (lambda (parameter)
                (format
                 "%s={%s}"
                 (substring
                  (symbol-name (car parameter))
                  1)
                 (cdr parameter)))
              parameters
              ",")
             "]"))
           (caption
            (org-latex--caption/label-string
             block
             info))
           (caption-above-p
            (org-latex--caption-above-p
             block
             info)))
      (concat
       (format "\\begin{%s}%s\n" type options)
       (and caption-above-p caption)
       contents
       (and (not caption-above-p) caption)
       (format "\\end{%s}" type)))))

(defun emarccs-shared--org-babellike-block--latex
    (original block contents info)
  "Extend `org-latex-special-block' for registered blocks."
  (emarccs-shared--org-babellike-block--export
   'latex
   original
   block
   contents
   info))

;;; HTML backend

(defun emarccs-shared--org-babellike-block--html-parameter-name
    (parameter)
  "Return a display name for PARAMETER."
  (capitalize
   (replace-regexp-in-string
    "-"
    " "
    (substring
     (symbol-name parameter)
     1))))

(defun emarccs-shared--org-babellike-block--render-html
    (original block contents parameters _info)
  "Render registered BLOCK for the HTML backend."
  (let ((metadata
         (when parameters
           (concat
            "<dl class=\"org-babellike-block-parameters\">\n"
            (mapconcat
             (lambda (parameter)
               (format
                "<dt class=\"org-babellike-block-parameter-name\">%s:</dt>\n\
<dd class=\"org-babellike-block-parameter-value\">%s</dd>"
                (emarccs-shared--org-babellike-block--html-parameter-name
                 (car parameter))
                (cdr parameter)))
             parameters
             "\n")
            "\n</dl>\n"))))
    ;; Delegate the outer container, ATTR_HTML handling, IDs, and
    ;; HTML5 special-block handling to `org-html-special-block'.
    (funcall
     original
     block
     (concat
      metadata
      "<div class=\"org-babellike-block-body\">\n"
      (or contents "")
      "\n</div>")
     _info)))

(defun emarccs-shared--org-babellike-block--html
    (original block contents info)
  "Extend `org-html-special-block' for registered blocks."
  (emarccs-shared--org-babellike-block--export
   'html
   original
   block
   contents
   info))

;;; Backend lifecycle

(defun emarccs-shared--org-babellike-block--install-backend
    (backend)
  "Install integration for BACKEND."
  (let* ((spec
          (emarccs-shared--org-babellike-block--backend-spec
           backend))
         (transcoder
          (plist-get spec :transcoder))
         (advice
          (plist-get spec :advice)))
    (unless spec
      (error
       "Unknown Babel-like block backend: %s"
       backend))

    (unless
        (advice-member-p
         advice
         transcoder)
      (advice-add
       transcoder
       :around
       advice))))

(defun emarccs-shared--org-babellike-block--activate-backend
    (backend)
  "Activate integration for BACKEND when its feature is loaded."
  (let* ((spec
          (emarccs-shared--org-babellike-block--backend-spec
           backend))
         (feature
          (plist-get spec :feature)))
    (unless spec
      (error
       "Unknown Babel-like block backend: %s"
       backend))

    ;; Important: if the backend is already loaded, install the
    ;; advice directly.  The current feature may still be in the
    ;; process of loading and therefore not yet satisfy `featurep'.
    (if (featurep feature)
        (emarccs-shared--org-babellike-block--install-backend
         backend)

      ;; Only the genuinely delayed path checks whether this
      ;; feature is still loaded.  The callback may outlive it
      ;; after `unload-feature'.
      (with-eval-after-load feature
        (when
            (featurep
             'emarccs-shared--org-babellike-block)
          (emarccs-shared--org-babellike-block--install-backend
           backend))))))

(defun emarccs-shared--org-babellike-block--uninstall-backend
    (backend)
  "Remove integration for BACKEND."
  (let* ((spec
          (emarccs-shared--org-babellike-block--backend-spec
           backend))
         (feature
          (plist-get spec :feature))
         (transcoder
          (plist-get spec :transcoder))
         (advice
          (plist-get spec :advice)))
    (when
        (and spec
             (featurep feature))
      (advice-remove
       transcoder
       advice))))

(defun emarccs-shared--org-babellike-block-unload-function ()
  "Unload `emarccs-shared--org-babellike-block'."
  (dolist
      (entry emarccs-shared--org-babellike-block--backend-registry)
    (emarccs-shared--org-babellike-block--uninstall-backend
     (car entry)))
  nil)

(dolist
    (entry emarccs-shared--org-babellike-block--backend-registry)
  (emarccs-shared--org-babellike-block--activate-backend
   (car entry)))

(provide 'emarccs-shared--org-babellike-block)
;;; emarccs-shared--org-babellike-block.el ends here.

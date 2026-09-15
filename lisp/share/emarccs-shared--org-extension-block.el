;;; emarccs-shared--org-extension-block.el --- Namespaced Org extension blocks -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(require 'org)
(require 'org-element)
(require 'ob-core)
(require 'ox)
(require 'subr-x)

(declare-function org-latex--caption/label-string
                  "ox-latex"
                  (element info))
(declare-function org-latex--caption-above-p
                  "ox-latex"
                  (element info))

(defconst emarccs-shared--org-extension-block--namespace
  "ext"
  "Org special-block namespace used for extension blocks.")

(defvar emarccs-shared--org-extension-block-registry nil
  "Registry of Org extension-block kinds.

Each entry has the form

  (KIND . PARAMETERS)

where KIND is the first positional token following `#+begin_ext'
and PARAMETERS is a list of allowed keyword parameters.

For example:

  ((\"reply\" . (:from :subject :date))
   (\"example\" . (:title)))

Source syntax has the form

  #+begin_ext KIND :KEY VALUE ...
  ...
  #+end_ext

Parameter syntax follows Babel header-argument syntax.  Parameter
values are interpreted semantically as Org secondary strings.

Normalization preserves the original `:parameters' property and
adds two properties to extension blocks:

  :extension-kind
  :extension-parameters

The latter contains validated parameter values in their original
Org secondary-string representation.")

(defcustom emarccs-shared--org-extension-block-preserve-namespace nil
  "Whether to preserve the `ext' namespace in backend output.

When nil, an extension block is lowered directly to its KIND in
the target backend.  For example,

  #+begin_ext example :title \"Example\"

is lowered to an `example' environment by the LaTeX backend.

When non-nil, the common `ext' namespace is preserved and KIND is
passed separately to the target backend.  The backend is then
responsible for interpreting the namespace.

This option affects only backend lowering.  It does not affect
the normalized Org AST."
  :type 'boolean
  :group 'org)

(defconst emarccs-shared--org-extension-block--secondary-string-restriction
  (org-element-restriction 'headline)
  "Restriction used to parse extension-block parameter values.")

(defconst emarccs-shared--org-extension-block--backend-registry
  '((latex
     :feature ox-latex
     :transcoder org-latex-special-block
     :advice emarccs-shared--org-extension-block--latex
     :renderer emarccs-shared--org-extension-block--render-latex)
    (html
     :feature ox-html
     :transcoder org-html-special-block
     :advice emarccs-shared--org-extension-block--html
     :renderer emarccs-shared--org-extension-block--render-html))
  "Backend definitions for Org extension blocks.")

;;; Extension-block parsing and normalization

(defun emarccs-shared--org-extension-block--namespace-block-p
    (block)
  "Return non-nil when BLOCK belongs to the extension namespace."
  (and
   (eq
    (org-element-type block)
    'special-block)
   (equal
    (downcase
     (or
      (org-element-property :type block)
      ""))
    emarccs-shared--org-extension-block--namespace)))

(defun emarccs-shared--org-extension-block--parse-head
    (block)
  "Parse the extension header of BLOCK.

Return a cons cell

  (KIND . PARAMETER-STRING)

where KIND is the first positional token and PARAMETER-STRING is
the remaining Babel-style header-argument string."
  (let ((raw
         (string-trim
          (or
           (org-element-property :parameters block)
           ""))))
    (when
        (string-empty-p raw)
      (user-error
       "%s block requires a kind"
       emarccs-shared--org-extension-block--namespace))

    (unless
        (string-match
         "\\`\\([^[:space:]]+\\)\\(?:[[:space:]]+\\(.*\\)\\)?\\'"
         raw)
      (user-error
       "Invalid %s block header: %s"
       emarccs-shared--org-extension-block--namespace
       raw))

    (let ((kind
           (match-string 1 raw))
          (parameter-string
           (string-trim
            (or
             (match-string 2 raw)
             ""))))
      (unless
          (or
           (string-empty-p parameter-string)
           (string-prefix-p ":" parameter-string))
        (user-error
         "Unexpected text after %s block kind %s: %s"
         emarccs-shared--org-extension-block--namespace
         kind
         parameter-string))

      (cons
       kind
       parameter-string))))

(defun emarccs-shared--org-extension-block--spec
    (kind)
  "Return the registry entry corresponding to KIND."
  (assoc-string
   kind
   emarccs-shared--org-extension-block-registry
   t))

(defun emarccs-shared--org-extension-block--parse-parameters
    (kind spec parameter-string)
  "Parse PARAMETER-STRING according to KIND and SPEC.

Return an alist whose keys are parameter keywords and whose
values are Org secondary strings in source representation."
  (let ((allowed
         (cdr spec))
        (parameters
         (org-babel-parse-header-arguments
          parameter-string
          t))
        seen)
    (dolist (parameter parameters)
      (let ((key
             (car parameter))
            (value
             (cdr parameter)))
        (unless
            (memq key allowed)
          (user-error
           "Unknown parameter for %s kind %s: %s"
           emarccs-shared--org-extension-block--namespace
           kind
           key))

        (unless value
          (user-error
           "Parameter %s for %s kind %s requires a value"
           key
           emarccs-shared--org-extension-block--namespace
           kind))

        (when
            (memq key seen)
          (user-error
           "Duplicate parameter for %s kind %s: %s"
           emarccs-shared--org-extension-block--namespace
           kind
           key))

        (push
         key
         seen)))

    ;; Babel may parse some literal values into non-string Lisp
    ;; objects.  Extension-block parameters are semantically Org
    ;; secondary strings, so normalize every value back to a
    ;; string at this boundary.
    (mapcar
     (lambda (parameter)
       (cons
        (car parameter)
        (if
            (stringp
             (cdr parameter))
            (cdr parameter)
          (format
           "%s"
           (cdr parameter)))))
     parameters)))

(defun emarccs-shared--org-extension-block--normalize-block
    (block)
  "Normalize extension semantics on BLOCK in place.

Ordinary special blocks are returned unchanged.  An `ext'
special block receives the properties `:extension-kind' and
`:extension-parameters'.

The original `:type' and `:parameters' properties are preserved."
  (when
      (emarccs-shared--org-extension-block--namespace-block-p
       block)
    (pcase-let*
        ((`(,source-kind . ,parameter-string)
          (emarccs-shared--org-extension-block--parse-head
           block))
         (spec
          (emarccs-shared--org-extension-block--spec
           source-kind)))

      (unless spec
        (user-error
         "Unknown %s block kind: %s"
         emarccs-shared--org-extension-block--namespace
         source-kind))

      ;; The registry spelling is canonical.  Source lookup itself
      ;; is case-insensitive.
      (let ((kind
             (car spec)))
        (org-element-put-property
         block
         :extension-kind
         kind)

        (org-element-put-property
         block
         :extension-parameters
         (emarccs-shared--org-extension-block--parse-parameters
          kind
          spec
          parameter-string)))))

  block)

(defun emarccs-shared--org-extension-block-normalize
    (data)
  "Normalize extension blocks in Org element DATA.

DATA is modified in place and returned.  Native Org element types
are preserved; extension blocks remain `special-block' elements
with additional normalized semantic properties."
  ;; Handle DATA itself when it is an extension block.
  (when
      (eq
       (org-element-type data)
       'special-block)
    (emarccs-shared--org-extension-block--normalize-block
     data))

  ;; Normalize extension blocks below DATA.
  (org-element-map
      data
      'special-block
    #'emarccs-shared--org-extension-block--normalize-block)

  data)

(defun emarccs-shared--org-extension-block-parse-buffer
    (&optional granularity visible-only)
  "Parse the current Org buffer and normalize extension blocks.

GRANULARITY and VISIBLE-ONLY are passed unchanged to
`org-element-parse-buffer'.

The returned tree is an ordinary Org element tree, but every
extension block has normalized `:extension-kind' and
`:extension-parameters' properties."
  (emarccs-shared--org-extension-block-normalize
   (org-element-parse-buffer
    granularity
    visible-only)))

;;; Backend-independent export

(defun emarccs-shared--org-extension-block--backend-spec
    (backend)
  "Return the backend specification corresponding to BACKEND."
  (cdr
   (assq
    backend
    emarccs-shared--org-extension-block--backend-registry)))

(defun emarccs-shared--org-extension-block--export-secondary-string
    (string block info)
  "Export STRING as an Org secondary string.

BLOCK is used as the parent syntax node.  INFO is the current
export environment."
  (org-export-data
   (org-element-parse-secondary-string
    string
    emarccs-shared--org-extension-block--secondary-string-restriction
    block)
   info))

(defun emarccs-shared--org-extension-block--export-parameters
    (block info)
  "Export normalized extension parameters of BLOCK using INFO."
  (mapcar
   (lambda (parameter)
     (cons
      (car parameter)
      (emarccs-shared--org-extension-block--export-secondary-string
       (cdr parameter)
       block
       info)))
   (org-element-property
    :extension-parameters
    block)))

(defun emarccs-shared--org-extension-block--export
    (backend original block contents info)
  "Export extension BLOCK through BACKEND.

ORIGINAL is the backend's original special-block transcoder.
Ordinary special blocks are delegated to ORIGINAL unchanged."
  (if
      (not
       (emarccs-shared--org-extension-block--namespace-block-p
        block))
      (funcall
       original
       block
       contents
       info)

    ;; Export operates on Org's export tree.  Apply exactly the same
    ;; normalization used by `...-parse-buffer' before any
    ;; backend-specific lowering.
    (emarccs-shared--org-extension-block--normalize-block
     block)

    (let ((backend-spec
           (emarccs-shared--org-extension-block--backend-spec
            backend)))
      (unless backend-spec
        (user-error
         "Unknown extension-block backend: %s"
         backend))

      (let ((renderer
             (plist-get
              backend-spec
              :renderer)))
        (unless renderer
          (user-error
           "No extension-block renderer registered for backend %s"
           backend))

        (funcall
         renderer
         original
         block
         (org-element-property
          :extension-kind
          block)
         contents
         (emarccs-shared--org-extension-block--export-parameters
          block
          info)
         info)))))

;;; LaTeX backend

(defun emarccs-shared--org-extension-block--render-latex
    (_original block kind contents parameters info)
  "Render extension BLOCK of KIND for the LaTeX backend."
  (when
      (org-export-read-attribute
       :attr_latex
       block
       :options)
    (user-error
     "%s blocks cannot use ATTR_LATEX :options; use extension parameters"
     emarccs-shared--org-extension-block--namespace))

  (let* ((options
          (when parameters
            (concat
             "["
             (mapconcat
              (lambda (parameter)
                (format
                 "%s={%s}"
                 (substring
                  (symbol-name
                   (car parameter))
                  1)
                 (cdr parameter)))
              parameters
              ",")
             "]")))
         (environment
          (if
              emarccs-shared--org-extension-block-preserve-namespace
              emarccs-shared--org-extension-block--namespace
            kind))
         (begin
          (if
              emarccs-shared--org-extension-block-preserve-namespace
              (format
               "\\begin{%s}{%s}%s\n"
               environment
               kind
               (or options ""))
            (format
             "\\begin{%s}%s\n"
             environment
             (or options ""))))
         (caption
          (org-latex--caption/label-string
           block
           info))
         (caption-above-p
          (org-latex--caption-above-p
           block
           info)))

    (concat
     begin
     (and
      caption-above-p
      caption)
     contents
     (and
      (not caption-above-p)
      caption)
     (format
      "\\end{%s}"
      environment))))

(defun emarccs-shared--org-extension-block--latex
    (original block contents info)
  "Extend `org-latex-special-block' for extension blocks."
  (emarccs-shared--org-extension-block--export
   'latex
   original
   block
   contents
   info))

;;; HTML backend

(defun emarccs-shared--org-extension-block--html-parameter-name
    (parameter)
  "Return a display name for PARAMETER."
  (capitalize
   (replace-regexp-in-string
    "-"
    " "
    (substring
     (symbol-name parameter)
     1))))

(defun emarccs-shared--org-extension-block--html-metadata
    (parameters)
  "Render extension PARAMETERS as HTML metadata."
  (when parameters
    (concat
     "<dl class=\"org-extension-block-parameters\">\n"
     (mapconcat
      (lambda (parameter)
        (format
         "<dt class=\"org-extension-block-parameter-name\">%s:</dt>\n\
<dd class=\"org-extension-block-parameter-value\">%s</dd>"
         (emarccs-shared--org-extension-block--html-parameter-name
          (car parameter))
         (cdr parameter)))
      parameters
      "\n")
     "\n</dl>\n")))

(defun emarccs-shared--org-extension-block--render-html
    (original block kind contents parameters info)
  "Render extension BLOCK of KIND for the HTML backend."
  (let ((metadata
         (emarccs-shared--org-extension-block--html-metadata
          parameters)))

    (if
        emarccs-shared--org-extension-block-preserve-namespace

        ;; Preserve the native `ext' outer special block.  KIND is
        ;; represented explicitly inside that namespace.
        (funcall
         original
         block
         (concat
          (format
           "<div class=\"org-extension-block-kind org-extension-block-%s\" \
data-extension-kind=\"%s\">\n"
           kind
           kind)
          metadata
          "<div class=\"org-extension-block-body\">\n"
          (or
           contents
           "")
          "\n</div>\n"
          "</div>")
         info)

      ;; Erase the source-level namespace by presenting a copy of
      ;; BLOCK to the stock HTML transcoder as a special block whose
      ;; type is the semantic KIND.  The export tree itself remains
      ;; normalized as `ext'.
      (let ((lowered-block
             (org-element-copy
              block)))
        (org-element-put-property
         lowered-block
         :type
         kind)

        ;; The original value is extension syntax, not native
        ;; special-block parameters, so do not expose it after
        ;; lowering.
        (org-element-put-property
         lowered-block
         :parameters
         nil)

        (funcall
         original
         lowered-block
         (concat
          metadata
          (or
           contents
           ""))
         info)))))

(defun emarccs-shared--org-extension-block--html
    (original block contents info)
  "Extend `org-html-special-block' for extension blocks."
  (emarccs-shared--org-extension-block--export
   'html
   original
   block
   contents
   info))

;;; Backend lifecycle

(defun emarccs-shared--org-extension-block--install-backend
    (backend)
  "Install integration for BACKEND."
  (let* ((spec
          (emarccs-shared--org-extension-block--backend-spec
           backend))
         (transcoder
          (plist-get
           spec
           :transcoder))
         (advice
          (plist-get
           spec
           :advice)))
    (unless spec
      (error
       "Unknown extension-block backend: %s"
       backend))

    (unless
        (advice-member-p
         advice
         transcoder)
      (advice-add
       transcoder
       :around
       advice))))

(defun emarccs-shared--org-extension-block--activate-backend
    (backend)
  "Activate integration for BACKEND when its feature is loaded."
  (let* ((spec
          (emarccs-shared--org-extension-block--backend-spec
           backend))
         (feature
          (plist-get
           spec
           :feature)))
    (unless spec
      (error
       "Unknown extension-block backend: %s"
       backend))

    ;; Important: if the backend is already loaded, install the
    ;; advice directly.  The current feature may still be in the
    ;; process of loading and therefore not yet satisfy `featurep'.
    (if
        (featurep feature)
        (emarccs-shared--org-extension-block--install-backend
         backend)

      ;; Only the genuinely delayed path checks whether this
      ;; feature is still loaded.  The callback may outlive it
      ;; after `unload-feature'.
      (with-eval-after-load feature
        (when
            (featurep
             'emarccs-shared--org-extension-block)
          (emarccs-shared--org-extension-block--install-backend
           backend))))))

(defun emarccs-shared--org-extension-block--uninstall-backend
    (backend)
  "Remove integration for BACKEND."
  (let* ((spec
          (emarccs-shared--org-extension-block--backend-spec
           backend))
         (feature
          (plist-get
           spec
           :feature))
         (transcoder
          (plist-get
           spec
           :transcoder))
         (advice
          (plist-get
           spec
           :advice)))
    (when
        (and
         spec
         (featurep feature))
      (advice-remove
       transcoder
       advice))))

(defun emarccs-shared--org-extension-block-unload-function ()
  "Unload `emarccs-shared--org-extension-block'."
  (dolist
      (entry
       emarccs-shared--org-extension-block--backend-registry)
    (emarccs-shared--org-extension-block--uninstall-backend
     (car entry)))
  nil)

(dolist
    (entry
     emarccs-shared--org-extension-block--backend-registry)
  (emarccs-shared--org-extension-block--activate-backend
   (car entry)))

(provide 'emarccs-shared--org-extension-block)
;;; emarccs-shared--org-extension-block.el ends here.

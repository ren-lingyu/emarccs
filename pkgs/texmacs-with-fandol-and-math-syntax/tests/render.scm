;; Render a native document without Emacs or Org-TeXmacs.
(use-modules (generic document-edit))

(begin
  (catch #t
         (lambda ()
           (load-buffer (system->url (getenv "EMARCCS_TM_INPUT")))
           (do ((pass 0 (+ pass 1))) ((= pass 3))
             (update-current-buffer))
           (update-forced)
           (print-to-file (system->url (getenv "EMARCCS_PDF_OUTPUT")))
           (do ((pass 0 (+ pass 1))) ((= pass 3))
             (update-current-buffer))
           (update-forced)
           (print-to-file (system->url (getenv "EMARCCS_PDF_OUTPUT")))
           (display "EMARCCS-RENDER-OK\n"))
         (lambda args
           (display "EMARCCS-RENDER-ERROR: ")
           (write args)
           (newline)))
  (quit-TeXmacs))

;;; builder.scm --- Nix builder for Emarccs byte-compile check

(use-modules (ice-9 format))

(define (getenv-required name)
  "Return environment variable NAME or terminate with an error."
  (or (getenv name)
      (error "Required environment variable is not set" name)))

(define (ensure-directory path)
  "Create PATH unless it already exists."
  (unless (file-exists? path)
    (mkdir path)))

(define emacs
  (getenv-required "EMACS"))

(define byte-compile-script
  (getenv-required "EMARCCS_BYTE_COMPILE_SCRIPT"))

(define home
  (getenv-required "HOME"))

(define out
  (getenv-required "out"))

;; Some packages loaded during byte compilation expect HOME to exist.
(ensure-directory home)

(format #t "Running Emacs byte-compile check~%")
(format #t "  Emacs: ~a~%" emacs)
(format #t "  Script: ~a~%" byte-compile-script)
(force-output)

;; `system*' does not invoke a shell.  It starts Emacs as a child process
;; and waits for it, returning the waitpid status.
(define status
  (system*
   emacs
   "--batch"
   "--load"
   byte-compile-script))

(define exit-code
  (status:exit-val status))

(define term-signal
  (status:term-sig status))

(cond
 ;; Normal successful exit.
 ((and exit-code (zero? exit-code))
  (ensure-directory out)
  (format #t "Emacs byte-compile check succeeded.~%")
  (force-output))

 ;; Normal non-zero exit.
 (exit-code
  (format (current-error-port)
          "Emacs byte-compile check failed with exit code ~a.~%"
          exit-code)
  (force-output (current-error-port))
  (exit exit-code))

 ;; Terminated by a signal.
 (term-signal
  (format (current-error-port)
          "Emacs byte-compile check was terminated by signal ~a.~%"
          term-signal)
  (force-output (current-error-port))
  (exit (+ 128 term-signal)))

 ;; This normally shouldn't happen for `system*'.
 (else
  (format (current-error-port)
          "Emacs returned an unexpected process status: ~s~%"
          status)
  (force-output (current-error-port))
  (exit 1)))

;;; builder.scm ends here

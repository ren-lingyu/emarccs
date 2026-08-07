;;; elisp-byte-compile.el --- Byte-compile Emarccs sources -*- lexical-binding: t; -*-

(require 'bytecomp)

(defun emarccs--getenv-required (name)
  "Return environment variable NAME or signal an error."
  (or (getenv name)
      (error "%s is not set" name)))

(setq straight-base-dir
      (emarccs--getenv-required
       "EMARCCS_STRAIGHT_BASE_DIR"))

(let* ((source
        (file-name-as-directory
         (emarccs--getenv-required
          "EMARCCS_ELISP_SOURCE")))

       ;; Deterministic order makes build logs reproducible.
       (files
        (sort
         (directory-files-recursively
          source
          "\\.el\\'")
         #'string<))

       (directories
        (delete-dups
         (mapcar #'file-name-directory files)))

       ;; Pretend project-local features have already been loaded.
       ;;
       ;; This prevents `require' forms from recursively loading Emarccs
       ;; source files while they are being checked independently.
       (local-features
        (mapcar
         (lambda (file)
           (intern (file-name-base file)))
         files))

       ;; BYTE-COMPILE-FILE expects an actual output pathname.
       ;;
       ;; In particular, do not use `null-device' here: a source file
       ;; declaring `no-byte-compile: t' is allowed to delete its
       ;; destination file.
       (dest-dir
        (make-temp-file
         "emarccs-byte-compile-"
         t))

       failed)

  ;; Let the byte compiler resolve all project-local source directories.
  (dolist (directory directories)
    (add-to-list 'load-path directory))

  (unwind-protect

      (progn
        (dolist (file files)
          (let* ((relative-file
                  (file-relative-name
                   file
                   source))

                 ;; Keep the original relative directory structure so
                 ;; identically named files cannot collide.
                 (dest-file
                  (expand-file-name
                   (concat
                    (file-name-sans-extension
                     relative-file)
                    ".elc")
                   dest-dir))

                 ;; `features' is a special variable, therefore this
                 ;; binding remains dynamic with lexical-binding enabled.
                 (features
                  (append local-features features))

                 (byte-compile-dest-file-function
                  (lambda (_file)
                    dest-file)))

            (make-directory
             (file-name-directory dest-file)
             t)

            (message "Checking %s" relative-file)

            (let ((result
                   (byte-compile-file file)))

              (cond
               ((eq result 'no-byte-compile)
                (message
                 "Skipped %s (no-byte-compile)"
                 relative-file))

               (result
                (message
                 "Passed %s"
                 relative-file))

               (t
                (setq failed t)
                (message
                 "Failed %s"
                 relative-file))))))

        (when failed
          (error
           "Failed to byte-compile one or more Emacs Lisp files"))

        (message
         "Emarccs byte-compile check completed successfully"))

    ;; The files are inside Nix's temporary build environment anyway,
    ;; but cleaning them here also makes this script pleasant to run
    ;; manually outside Nix.
    (delete-directory dest-dir t)))

;;; elisp-byte-compile.el ends here

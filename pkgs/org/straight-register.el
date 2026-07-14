(org
 :type git
 :host nil
 :repo "https://git.tecosaur.net/tec/org-mode.git"
 :branch "dev"
 :remote "tecosaur"
 :files (:defaults "etc")
 :build t
 :pre-build
 (with-temp-file "org-version.el"
   (require 'lisp-mnt)
   (let ((version
          (with-temp-buffer
            (insert-file-contents "lisp/org.el")
            (lm-header "version")))
         (git-version
          (string-trim
           (with-temp-buffer
             (call-process "git" nil t nil "rev-parse" "--short" "HEAD")
             (buffer-string)))))
     (insert
      (format "(defun org-release () \"The release version of Org.\" %S)\n" version)
      (format "(defun org-git-version () \"The truncate git commit hash of Org mode.\" %S)\n" git-version)
      "(provide 'org-version)\n"))))

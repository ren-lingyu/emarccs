;;; emarccs-shared-org-roam-blog.el --- Configure the personal Org-roam blog -*- lexical-binding: t; -*-

;;; commentary:
;;; code:

(use-package citeproc)

(defconst emarccs-shared--org-roam-blog-site-name "aRenCoco's Blog")
(defconst emarccs-shared--org-roam-blog-site-url "https://aren-coco.com")
(defconst emarccs-shared--org-roam-blog-beginning-year 2026)

;; License strings.
(defconst emarccs-shared--org-roam-blog-cc-license-generic-work-full-tool-name
  (concat "This work is licensed under" "\u0020"
          "<a rel=\"license\" href=\"https://creativecommons.org/licenses/by-nc-sa/4.0/\">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International</a>"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/cc.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/by.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/nc.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/sa.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"))

(defconst emarccs-shared--org-roam-blog-cc-license-no-geniric-work-full-tool-name
  (concat "&copy;"
          (if (= (string-to-number (format-time-string "%Y"))
                 emarccs-shared--org-roam-blog-beginning-year)
              (number-to-string emarccs-shared--org-roam-blog-beginning-year)
            (concat (number-to-string emarccs-shared--org-roam-blog-beginning-year)
                    "-"
                    (format-time-string "%Y")))
          "\u0020"
          "<a rel=\"cc:attributionURL\" href=\""
          emarccs-shared--org-roam-blog-site-url
          "/\">aRenCoco</a>"
          "\u0020"
          "\u00B7"
          "\u0020"
          "<a rel=\"license\" href=\"https://creativecommons.org/licenses/by-nc-sa/4.0/\">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International</a>"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/cc.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/by.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/nc.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/sa.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"))

(defconst emarccs-shared--org-roam-blog-cc-license-no-genic-work-no-full-tool-name
  (concat "&copy;"
          (if (= (string-to-number (format-time-string "%Y"))
                 emarccs-shared--org-roam-blog-beginning-year)
              (number-to-string emarccs-shared--org-roam-blog-beginning-year)
            (concat (number-to-string emarccs-shared--org-roam-blog-beginning-year)
                    "-"
                    (format-time-string "%Y")))
          "\u0020"
          "<a rel=\"cc:attributionURL\" href=\""
          emarccs-shared--org-roam-blog-site-url
          "/\">aRenCoco</a>"
          "\u0020"
          "\u00B7"
          "\u0020"
          "<a rel=\"license\" href=\"https://creativecommons.org/licenses/by-nc-sa/4.0/\">CC BY-NC-SA 4.0</a>"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/cc.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/by.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/nc.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"
          "<img src=\"https://mirrors.creativecommons.org/presskit/icons/sa.svg\" alt=\"\" style=\"max-width: 1em;max-height:1em;margin-left: .2em;\">"))

;; Blog configuration.
(defun emarccs-shared--org-roam-blog-article-body (context)
  "Prepend publication metadata to the article body in CONTEXT."
  (let ((format-value (lambda (value)
                        (condition-case nil
                            (let ((time
                                   (cond ((numberp value) (seconds-to-time value))
                                         ((stringp value) (org-time-string-to-time value))
                                         ((listp value) value)
                                         (t nil))))
                              (if time
                                  (format-time-string "%Y-%m-%d %z"
                                                      time)
                                ""))
                          (error "")))))
    (concat "<div class=\"post-status\">\n"
            "<span>\n"
            "<i class='bx bx-calendar'></i>\n"
            "<span>\n"
            (funcall format-value
                     (plist-get context
                                :published-time))
            "</span>\n"
            "</span>\n"
            "<span>\n"
            "<i class='bx bx-edit'></i>\n"
            "<span>"
            (funcall format-value
                     (plist-get context
                                :modified-time))
            "</span>\n"
            "</span>\n"
            "</div>\n"
            "\n"
            (plist-get context
                       :body))))

(defun emarccs-shared--org-roam-blog-sitemap-renderer (context)
  "Render the blog sitemap Org source fragment from CONTEXT."
  (let* ((entries (plist-get context
                             :entries))
         (config (plist-get context
                            :config))
         (present-tags (delete-dups (apply #'append
                                           (mapcar (lambda (entry)
                                                     (copy-sequence (plist-get entry
                                                                               :tags)))
                                                   entries))))
         (tags (delq nil
                     (mapcar (lambda (tag)
                               (and (member tag
                                            present-tags)
                                    tag))
                             (plist-get config
                                        :visible-tags)))))
    (concat (mapconcat (lambda (head_extra)
                         (format "#+HTML_HEAD_EXTRA: %s\n"
                                 head_extra))
                       (apply #'append
                              (list '("<style>")
                                    (list "li:has(.filetags){display: none;}"
                                          ".content:has([value=\"all\"]:checked)"
                                          "li{display: list-item;}")
                                    (mapcar (lambda (tag)
                                              (let* ((sharp_tag (concat "#" tag)))
                                                (format ".content:has([value=\"%s\"]:checked) li:has([data-filetags~=\"%s\"]){display: list-item;}"
                                                        sharp_tag
                                                        sharp_tag)))
                                            tags)
                                    '("</style>"))))
            (mapconcat (lambda (macro)
                         (format "#+MACRO: %s\n"
                                 macro))
                       (list "timestamp @@html:<span class=\"timestamp\">[$1]</span>@@"
                             "filetags @@html:<span class=\"filetags\" data-filetags=\"$1\"></span>@@"))
            "#+BEGIN_EXPORT html\n"
            "<section class=\"filter\">\n"
            "<label class=\"category\">\n"
            "<input type=\"radio\" name=\"tag\" value=\"all\" checked/>\n"
            "<span>all</span>\n"
            "</label>\n"
            (mapconcat (lambda (tag)
                         (format (concat "<label class=\"category\">\n"
                                         "<input type=\"radio\" name=\"tag\" value=\"%s\"/>\n"
                                         "<span>%s</span>\n"
                                         "</label>\n")
                                 tag
                                 tag))
                       tags
                       "\n")
            "</section>\n"
            "#+END_EXPORT\n"
            (mapconcat (lambda (entry)
                         (let ((published (condition-case nil
                                              (format-time-string "%Y-%m-%d %a %z"
                                                                  (org-time-string-to-time
                                                                   (plist-get entry
                                                                              :published-time)))
                                            (error "")))
                               (title (or (plist-get entry
                                                     :title)
                                          (plist-get entry
                                                     :source-relative)))
                               (url (plist-get entry
                                               :store-url))
                               (tags (plist-get entry
                                                :tags)))
                           (format "- {{{timestamp(%s)}}} [[file:%s][%s]] {{{filetags(%s)}}}\n"
                                   published
                                   url
                                   title
                                   (mapconcat #'identity
                                              tags
                                              "\u0020"))))
                       entries))))

;; org-roam-blog configuration
(use-package org-roam-blog
  :after org-roam
  :custom
  (org-roam-blog-directory (expand-file-name "./roam/permanent/"
                                             org-directory))
  (org-roam-blog-publish-directory (expand-file-name "./public/"
                                                     org-directory))
  (org-roam-blog-publish-store "store")
  (org-roam-blog-site-url (concat emarccs-shared--org-roam-blog-site-url "/"))
  (org-roam-blog-published-property "PUBLISHED")
  (org-roam-blog-sitemap (list :enable t
                               :path "./sitemap.html"
                               :preamble (concat "#+TITLE: Post\n"
                                                 "#+DESCRIPTION: The map of blog posting, sorted by PUBLISHED DATE and categorized by FILESTAGS.\n"
                                                 "#+BEGIN_abstract\n"
                                                 "The map of blog posting, sorted by PUBLISHED DATE and categorized by FILESTAGS.\n"
                                                 "#+END_abstract\n")
                               :sort 'anti-chronologically
                               :visible-tags '("2026" "日常" "年度总结" "随笔")
                               :renderer #'emarccs-shared--org-roam-blog-sitemap-renderer))
  (org-roam-blog-theindex (list :enable t
                                :path "./theindex.html"
                                :preamble (concat "#+TITLE: Index\n"
                                                  "#+DESCRIPTION: The website index, sorted by the first letter of the title.\n"
                                                  "#+BEGIN_abstract\n"
                                                  "The website index, sorted by the first letter of the title."
                                                  "\n"
                                                  "#+END_abstract\n")))
  (org-roam-blog-content (list (list :name "index"
                                     :tags '("blog" "index")
                                     :directory "./"
                                     :sitemap nil
                                     :theindex t)
                               (list :name "post"
                                     :tags '("blog" "post")
                                     :directory nil
                                     :sitemap t
                                     :theindex t
                                     :template (list :with-toc t
                                                     :section-numbers t)
                                     :body (list #'emarccs-shared--org-roam-blog-article-body))))
  (org-roam-blog-static (list (list :source (expand-file-name "./static/"
                                                              org-directory)
                                    :directory "./"
                                    :extensions "css\\|js\\|svg")))
  (org-roam-blog-export-default (list :template (list :author "aRenCoco"
                                                      :email "aRen_Coco@outlook.com"
                                                      :with-author t
                                                      :with-email t
                                                      :headline-levels 5
                                                      :with-toc nil
                                                      :with-creator t
                                                      :with-timestamp t
                                                      :with-planning t
                                                      :html-link-home "/index.html"
                                                      :html-preamble t
                                                      :html-postamble t
                                                      :section-numbers nil)
                                      :bindings (list (cons 'org-html-head
                                                            (concat "<link rel=\"stylesheet\" href=\"https://font.aren-coco.com/MapleMono-NF-CN-Regular/result.css\"/>\n"
                                                                    "<link rel=\"stylesheet\" href=\"https://font.aren-coco.com/LXGWWenKai-Regular/result.css\"/>\n"
                                                                    "<link rel=\"stylesheet\" href=\"https://cdn.boxicons.com/3.0.8/fonts/basic/boxicons.min.css\"/>\n"
                                                                    "<link rel=\"icon\" type=\"image/svg+xml\" href=\"/favicon.svg\"/>\n"
                                                                    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/org-html-style-default.css?v="
                                                                    (format-time-string "%Y%m%d%z")
                                                                    "\"/>\n"
                                                                    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/org-html-style-local.css?v="
                                                                    (format-time-string "%Y%m%d%z")
                                                                    "\"/>\n"
                                                                    "<link rel=\"alternate\" type=\"application/atom+xml\" title=\""
                                                                    emarccs-shared--org-roam-blog-site-name
                                                                    " - Atom\" href=\"/feed.atom\"/>\n"))
                                                      (cons 'org-html-head-extra
                                                            nil)
                                                      (cons 'org-html-head-include-default-style
                                                            nil)
                                                      (cons 'org-html-home/up-format
                                                            "<div class=\"flexbox\">\n")
                                                      (cons 'org-html-preamble-format
                                                            `(("en"
                                                               ,(concat "\n"
                                                                        "<header>\n"
                                                                        "<nav>\n"
                                                                        "<a accesskey=\"\" href=\"/index.html\">aRenCoco's Blog</a>\n"
                                                                        "<a accesskey=\"\" href=\"/sitemap.html\">Post</a>\n"
                                                                        "<a accesskey=\"\" href=\"/about.html\">About</a>\n"
                                                                        "<a accesskey=\"\" href=\"/style.html\">Style</a>\n"
                                                                        "<a accesskey=\"\" href=\"/theindex.html\">Index</a>\n"
                                                                        "<a accesskey=\"\" href=\"" emarccs-shared--org-roam-blog-site-url "/feed.atom\">Feed</a>\n"
                                                                        "</nav>\n"
                                                                        "</header>\n"
                                                                        "<hr class=\"topline\">\n\n"))))
                                                      (cons 'org-html-postamble-format
                                                            `(("en"
                                                               ,(concat "\n"
                                                                        "<footer>\n"
                                                                        "<p>\n"
                                                                        emarccs-shared--org-roam-blog-cc-license-no-genic-work-no-full-tool-name
                                                                        "</p>\n"
                                                                        "<p>\n"
                                                                        "Generated at <span class=\"update-time\">%T</span> by %c on <a href=\"https://nixos.org\">NixOS</a>."
                                                                        "</p>\n"
                                                                        "</footer>\n"
                                                                        "</div>\n"
                                                                        "\n"))))
                                                      (cons 'org-html-metadata-timestamp-format
                                                            "%Y-%m-%d %a %H:%M %z")))))

(provide 'emarccs-shared-org-roam-blog)

;;; emarccs-shared-org-roam-blog.el ends here

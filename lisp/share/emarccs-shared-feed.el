;;; emarccs-shared-feed.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

(use-package elfeed
  :config
  (setq elfeed-feeds '(("https://aren-coco.com/feed.atom" blog)
                       ("https://langxubai.com/rss.xml" blog)
                       ("https://rss.arxiv.org/atom/cond-mat.str-el" arXiv))))

(use-package elfeed-dashboard
  :disabled)

(use-package elfeed-org
  :disabled)

(use-package arxiv-mode
  :config
  (setq arxiv-use-variable-pitch t)
  (setq arxiv-pop-up-new-frame t)
  (setq arxiv-default-category "cond-mat")
  (setq arxiv-frame-alist '((name . "*arXiv*"))))

(provide 'emarccs-shared-feed)
;;; emarccs-shared-feed.el ends here.

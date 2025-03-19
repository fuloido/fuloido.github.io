;;; publish.el ---generate and publish blog -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 fuloido
;;
;; Author: fuloido <me@fuloido.moe>
;; Maintainer: fuloido <me@fuloido.moe>
;; Created: March 18, 2025
;; Modified: March 18, 2025
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
;; Homepage: https://github.com/floydtao/publish
;; Package-Requires: ((emacs "24.4"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Building an Org-mode blog.
;;
;;; Code:

(add-to-list 'load-path "elisp")
(require 'org)
(require 'ox-publish)
(require 'htmlize)

(setq org-html-htmlize-output-type 'css)

(setq org-publish-project-alist
        `(("pages"
           :base-directory "./src/"
           :base-extension "org"
           :recursive t
           :html-postamble "<p class=\"author\">Author: %a (%e)</p>\n<p class=\"date\">Date: %d</p>\n"
           :publishing-directory "./public/"
           :publishing-function org-html-publish-to-html)

          ("static"
           :base-directory "./src/"
           :base-extension "css\\|txt\\|jpg\\|gif\\|png\\|html\\|tff\\|woff2"
           :recursive t
           :publishing-directory  "./public/"
           :publishing-function org-publish-attachment)

          ("fuloido.moe" :components ("pages" "static"))))

(org-publish "fuloido.moe" t)

(print "Publish Done")

;;; publish.el ends here

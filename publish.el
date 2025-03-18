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

(require 'ox-publish)

(setq org-publish-project-alist
        `(("pages"
           :base-directory "./src/"
           :base-extension "org"
           :recursive t
           :publishing-directory "./public/"
           :publishing-function org-html-publish-to-html)

          ("static"
           :base-directory "./src/"
           :base-extension "css\\|txt\\|jpg\\|gif\\|png\\|html"
           :recursive t
           :publishing-directory  "./public/"
           :publishing-function org-publish-attachment)

          ("fuloido.moe" :components ("pages" "static"))))

(org-publish-all t)

;;; publish.el ends here

;; -*- no-byte-compile: t; -*-

(package! code-review
    :recipe (:host github
             :repo "phelrine/code-review"
             :branch "fix/closql-update"
             :files ("graphql" "code-review*.el")))
(package! sqlite3)

(package! pkgbuild-mode
  :recipe (:host github :repo "juergenhoetzel/pkgbuild-mode"))

(unpin! doom-themes)

(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el"))

(unpin! org-roam)
(package! org-roam-ui)

(package! org-ref)

(package! org-padding
  :recipe (:host github :repo "TonCherAmi/org-padding"))

(package! xah-wolfram-mode
  :recipe (:host github :repo "xahlee/xah-wolfram-mode"))

(unpin! spell-fu)

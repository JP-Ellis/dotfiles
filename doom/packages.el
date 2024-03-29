;; -*- no-byte-compile: t; -*-

(unpin! t)

(package! code-review
    :recipe (:host github
             :repo "phelrine/code-review"
             :branch "fix/closql-update"
             :files ("graphql" "code-review*.el")))
(package! sqlite3)

(package! pkgbuild-mode)

(package! bicep-mode
  :recipe (:host github :repo "christiaan-janssen/bicep-mode"))

(unpin! doom-themes)

(package! copilot
  :recipe (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el")))

(unpin! org-roam)
(package! org-roam-ui)

(package! org-ref)

(package! org-padding
  :recipe (:host github :repo "TonCherAmi/org-padding"))

(package! xah-wolfram-mode
  :recipe (:host github :repo "xahlee/xah-wolfram-mode"))

(unpin! spell-fu)

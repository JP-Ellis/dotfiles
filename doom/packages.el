;; -*- no-byte-compile: t; -*-

(package! pkgbuild-mode)

(package! bicep-mode
  :recipe (:host github :repo "christiaan-janssen/bicep-mode"))

(package! copilot
  :recipe (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el")))

(unpin! org-roam)
(package! org-roam-ui)

(package! org-ref)

(package! org-padding
  :recipe (:host github :repo "TonCherAmi/org-padding"))

(package! xah-wolfram-mode
  :recipe (:host github :repo "xahlee/xah-wolfram-mode"))

;; -*- no-byte-compile: t; -*-

(package! pkgbuild-mode
  :recipe (:host github :repo "juergenhoetzel/pkgbuild-mode"))

(package! astro-ts-mode
  :recipe (:host github :repo "Sorixelle/astro-ts-mode"))

(unpin! doom-themes)

(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el"))

(package! org-ref)

(package! org-padding
  :recipe (:host github :repo "TonCherAmi/org-padding"))

(unpin! spell-fu)

(package! svelte-mode
  :recipe (:host github :repo "leafOfTree/svelte-mode"))

(package! xah-wolfram-mode
  :recipe (:host github :repo "xahlee/xah-wolfram-mode"))

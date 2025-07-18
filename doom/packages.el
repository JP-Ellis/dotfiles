;; -*- no-byte-compile: t; -*-

(unpin! forge)

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

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(python-mode . ("ruff" "server"))))

(unpin! spell-fu)

(package! xah-wolfram-mode
  :recipe (:host github :repo "xahlee/xah-wolfram-mode"))

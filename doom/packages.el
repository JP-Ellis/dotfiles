;; -*- no-byte-compile: t; -*-

(package! pkgbuild-mode)

(package! copilot
  :recipe (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el")))

(package! xah-wolfram-mode
  :recipe (:host github :repo "xahlee/xah-wolfram-mode"))

;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find a "Module Index" link where you'll find
;;      a comprehensive list of Doom's modules and what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c c k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;      directory (for easy access to its source code).

(doom!
 :input
 ;; bidi
 ;; chinese
 ;; japanese
 ;; layout                     ; auie,ctsrnm is the superior home row

 :completion
 ;; (company                   ; the ultimate code completion backend
 ;;  +childframe)
 (corfu                        ; corfu completion backend
  +orderless
  +icons)
 ;; helm                       ; the *other* search engine for love and life
 ;; ido                        ; the other *other* search engine...
 ;; ivy                        ; a search engine for love and life
 (vertico                      ; the search engine of the future
  +childframe
  +icons)

 :ui
 deft                          ; notational velocity for Emacs
 doom                          ; what makes DOOM look the way it does
 doom-dashboard                ; a nifty splash screen for Emacs
 doom-quit                     ; DOOM quit-message prompts when you quit Emacs
 (emoji
  +ascii
  +github
  +unicode)                    ; 🙂
 hl-todo                       ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
 ;; hydra
 ;; indent-guides              ; highlighted indent columns
 ligatures                     ; ligatures and symbols to make your code pretty again
 minimap                       ; show a map of the code on the side
 modeline                      ; snazzy, Atom-inspired modeline, plus API
 nav-flash                     ; blink cursor line after big motions
 neotree                       ; a project drawer, like NERDTree for vim
 ophints                       ; highlight the region an operation acts on
 (popup                        ; tame sudden yet inevitable temporary windows
  +defaults)
 ;; tabs                       ; a tab bar for Emacs
 (treemacs                     ; a project drawer, like neotree but cooler
  +lsp)
 unicode                       ; extended unicode support for various languages
 (vc-gutter                    ; vcs diff in the fringe
  +pretty)
 vi-tilde-fringe               ; fringe tildes to mark beyond EOB
 (window-select
  +numbers
  +switch-window)              ; visually switch windows
 workspaces                    ; tab emulation, persistence & separate workspaces
 zen                           ; distraction-free coding or writing

 :editor
 (evil                         ; come to the dark side, we have cookies
  +everywhere)
 file-templates                ; auto-snippets for empty files
 fold                          ; (nigh) universal code folding
 (format                       ; automated prettiness
  +onsave)
 ;; god                        ; run Emacs commands without modifier keys
 ;; lispy                      ; vim for lisp, for people who don't like vim
 multiple-cursors              ; editing in many places at once
 ;; objed                      ; text object editing for the innocent
 ;; parinfer                   ; turn lisp into python, sort of
 rotate-text                   ; cycle region at point between text candidates
 snippets                      ; my elves. They type so I don't have to
 word-wrap                     ; soft wrapping with language-aware indent

 :emacs
 (dired                        ; making dired pretty [functional]
  +icons
  +dirvish)
 electric                      ; smarter, keyword-based electric-indent
 (ibuffer                      ; interactive buffer management
  +icons)
 (undo                         ; persistent, smarter undo for your inevitable mistakes
  +tree)
 vc                            ; version-control and Emacs, sitting in a tree

 :term
 eshell                        ; the elisp shell that works everywhere
 (:if (featurep :system 'windows) shell)        ; simple shell REPL for Emacs
 ;; term                       ; basic terminal emulator for Emacs
 (:if (not (featurep :system 'windows)) vterm)  ; the best terminal emulation in Emacs

 :checkers
 grammar                       ; tasing grammar mistake every you make
 (spell                        ; tasing you for misspelling mispelling  ; codespell:ignore
  +aspell
  +everywhere)                 ; Spell check in comments of programming mode
 (syntax                       ; tasing you for every semicolon you forget
  +childframe)

 :tools
 ;; ansible
 biblio                        ; Writes a PhD for you (citation needed)
 ;; collab                     ; Collaborative editing via crdt
 (debugger                     ; FIXME stepping through code, to help you add bugs
  +lsp)
 (:if (not (featurep :system 'windows)) direnv)
 docker
 editorconfig                  ; let someone else argue about tabs vs spaces
 ;; ein                           ; tame Jupyter notebooks with emacs ; codespell:ignore
 (eval                         ; run code, run (also, repls)
  +overlay)
 lookup                        ; navigate your code and its documentation
 (lsp                          ; M-x vscode
  +peek
  +eglot)
 (magit                        ; a git porcelain for Emacs
  +forge)
 make                          ; run make tasks from Emacs
 ;; pass                       ; password manager for nerds
 pdf                           ; pdf enhancements
 ;; prodigy                    ; FIXME managing external services & code builders
 ;; (terraform                 ; infrastructure as code
 ;;  +lsp)
 ;; tmux                       ; an API for interacting with tmux
 tree-sitter
 upload                        ; map local to remote projects via ssh/ftp

 :os
 (:if (featurep :system 'macos) macos)            ; improve compatibility with macOS
 (tty                          ; improve the terminal Emacs experience
  +osc)

 :lang
 ;; (agda +tree-sitter)        ; types of types of types of types...
 (beancount +lsp)           ; mind the GAAP
 (cc +lsp +tree-sitter)        ; C > C++ == 1
 ;; (clojure +lsp +tree-sitter) ; java with a lisp
 ;; common-lisp                ; if you've seen one lisp, you've seen them all
 ;; coq                        ; proofs-as-programs
 ;; crystal                    ; ruby at the speed of c
 ;; (csharp +lsp +tree-sitter  ; unity, .NET, and mono shenanigans
 ;;  +dotnet
 ;;  +unity)
 ;; (dart +lsp                 ; paint ui and not much else
 ;;  +flutter)
 data                          ; config/data formats
 ;; dhall
 ;; (elixir +lsp +tree-sitter) ; erlang done right
 ;; (elm +lsp +tree-sitter)         ; care for a cup of TEA?
 emacs-lisp                    ; drown in parentheses
 ;; (erlang +lsp +tree-sitter) ; an elegant language for a more civilized age
 ;; (ess +stan +tree-sitter)   ; emacs speaks statistics
 ;; factor
 ;; faust                      ; dsp, but you get to keep your soul
 ;; (fortran +lsp)             ; in FORTRAN, GOD is REAL (unless declared INTEGER)
 ;; (fsharp +lsp)              ; ML stands for Microsoft's Language
 ;; fstar                      ; (dependent) types and (monadic) effects and Z3
 ;; (gdscript +lsp)            ; the language you waited for
 ;; (go +lsp +tree-sitter)     ; the hipster dialect
 (graphql +lsp)
 ;; (haskell +lsp +tree-sitter) ; a language that's lazier than I am
 ;; hy                         ; readability of scheme w/ speed of python
 ;; idris                      ; a language you can depend on
 (java +lsp +tree-sitter)      ; the poster child for carpal tunnel syndrome
 (javascript +lsp +tree-sitter) ; all(hope(abandon(ye(who(enter(here))))))
 (json +lsp +tree-sitter)      ; At least it ain't XML
 ;; (julia +lsp +tree-sitter +snail)  ; a better, faster MATLAB
 ;; (kotlin +lsp)              ; a better, slicker Java(Script)
 (latex +lsp                   ; writing papers in Emacs has never been so fun
        +latexmk
        +cdlatex
        +fold)
 ;; lean                       ; for folks with too much to prove
 ;; ledger                     ; be audit you can be
 (lua +lsp +tree-sitter)       ; one-based indices? one-based indices
 (markdown
  +grip)                       ; writing docs for people to ignore
 ;; nim                        ; python + lisp at the speed of c
 ;; (nix +lsp +tree-sitter)    ; I hereby declare "nix geht mehr!"
 ;; (ocaml +lsp +tree-sitter)  ; an objective camel
 (org                          ; organize your plain life in plain text
  +brain
  +contacts
  +dragndrop
  +crypt
  +gnuplot
  +hugo
  +journal
  +jupyter
  +noter
  +pandox
  +passwords
  +pomodoro
  +present
  +pretty
  +roam2)
 ;; (php +lsp +tree-sitter)    ; perl's insecure younger brother
 ;; plantuml                   ; diagrams for confusing people more
 ;; purescript                 ; javascript, but functional
 (python +lsp                  ; beautiful is better than ugly
         +tree-sitter
         ;; +conda
         ;; +cython
         +poetry
         +pyenv
         +pyright)
 ;; qt                         ; the 'cutest' gui framework ever
 ;; (racket +lsp +xp)          ; a DSL for DSLs
 ;; raku                       ; the artist formerly known as perl6
 (rest                         ; Emacs as a REST client
  +jq)                         ; With support for jq
 rst                           ; ReST in peace
 (ruby +lsp +tree-sitter       ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       +chruby
       +rails
       +rbenv
       +rvm)
 (rust +lsp +tree-sitter)      ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
 (scala +lsp +tree-sitter)     ; java, but good
 ;; (scheme                    ; a fully conniving family of lisps
 ;;  +chez
 ;;  +chibi
 ;;  +chicken
 ;;  +gambit
 ;;  +gauche
 ;;  +guile
 ;;  +kawa
 ;;  +mit
 ;;  +racket)
 (sh +lsp +tree-sitter         ; she sells {ba,z,fi}sh shells on the C xor  ; codespell:ignore
     +fish
     +powershell)
 ;; sml
 ;; solidity                   ; do you need a blockchain? No.
 ;; (swift +lsp +tree-sitter)  ; who asked for emoji variables?
 ;; terra                      ; Earth and Moon in alignment for performance.
 (web +lsp +tree-sitter)       ; the tubes
 (yaml +lsp +tree-sitter)      ; JSON, but readable
 ;; (zig +lsp +tree-sitter)         ; C, but simpler

 :email
 ;; (mu4e +org +gmail)
 ;; (notmuch +afew +org)
 ;; (wanderlust +gmail)

 :app
 calendar
 ;; emms
 ;; everywhere                 ; *leave* Emacs!? You must be joking
 ;; irc                        ; how neckbeards socialize
 ;; (rss +org)                 ; emacs as an RSS reader

 :config
 (default                      ; Reasonable default
  +bindings                   ; Doom's default keybindings
  +smartparens)               ; Doom's configuration for smartparesn
 literate)                     ; Generate configs from org-mode

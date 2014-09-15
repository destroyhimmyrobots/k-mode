;; -----------------------------------------------------------------------------
;; This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
;; To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/
;; or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
;; -----------------------------------------------------------------------------
;; File:        k-mode.el
;; Description: k3.3 major mode for emacs.
;; Author:      Marc J. Szalkiewicz
;; Date:        2014-09-15
;; -----------------------------------------------------------------------------

(defvar k-mode-hook nil)

(defconst k-faces
  '(("const" font-lock-constant-face)
    ("cmd" font-lock-preprocessor-face)
    ("io" font-lock-builtin-face)
    ("var" font-lock-constant-face)
    ("cmt" font-lock-comment-face)
    ("cmt-delim" font-lock-comment-delimiter-face)
    ("atom-sym" font-lock-type-face)
    ("vect-cha" font-lock-string-face)
    ("verb" font-lock-function-name-face)
    ("builtin" font-lock-builtin-face)
    ("ctrl" font-lock-keyword-face)
    ("adverb" font-lock-keyword-face)))

(defmacro k-init-faces ()
  `(progn ,@(mapcar (lambda (tpl)
                      `(defface ,(intern (format "k-%s-face" (car tpl)))
                         '((t (:inherit ,(cdr tpl))))
                         ,(format "Face for k-%s." (car tpl))
                         :group 'k-mode))
                    k-faces)))
(k-init-faces)

(defconst k-verbs
  (regexp-opt '("+" "-" "*" "%" "&" "|" "<" ">" "="
                "^" "!" "~" "," "#" "$" "?" "@" ".") ;;"_")
                t))
(defconst k-system-verbs-nouns
  (regexp-opt
   (mapcar #'(lambda (x)         ;; Math
               (concat "_" x)) '("log" "exp" "abs" "sqrt" "floor"
                                 "dot" "mul" "inv"
                                 "sin" "cos" "tan"
                                 "asin" "acos" "atan"
                                 "sinh" "cosh" "tanh" "lsq"
                                 ;; Random
                                 "draw"
                                 ;; Time
                                 "t" "lt" "gtime" "jd" "dj"
                                 ;; List
                                 "in" "lin"
                                 "bin" "binl"
                                 "dv" "di" "dvl"
                                 "sv" "vs"
                                 "ci" "ic"
                                 "sm" "ss" "ssr"
                                 "bd" "db"
                                 "host" "host" "size" "exit"
                                 ;; Vars
                                 "d" "v" "i" "t" "f" "n" "s"
                                 "h" "p" "w" "u" "a" "k" "T")) nil))
(defconst k-cmds
  (regexp-opt (mapcar #'(lambda (x) (concat "\\" x))
                      '("a" "g" "l" "s" "w" "b" "\\"
                        "d" "v" "i" "p" "t" "r" "cd")) nil))
(defconst k-system-io
  (regexp-opt (append (list ".m.u" ".m.s" ".m.g" ".m.c")
                      (list "`0:" "0:" "1:" "2:" "5:" "6:"))) nil)
(defconst k-data
  (regexp-opt '("4:" "5:") nil))
(defconst k-os-dialog
  (regexp-opt '("`3:" "`4:") nil))
(defconst k-control
  (regexp-opt '("if" "do" "while") t))
(defconst k-const
  (regexp-opt '("0#0.0" "!0" "0I" "0N" "0i" "0n" "0Ij" "0Nj"
                "0#`" "\"\\000\"" "\"\\0\"") nil))

(defconst k-font-lock-keywords-0
  (list
   '("\\(?:[[:space:]^]/.*\\)$" . 'k-cmt-face)
   '("\\(?:\"[^\"]*\"\\)" . 'k-vect-cha-face)
   '("\\(?:`\\(?:\"[^\"]*\"\\|[^0-9][[:alnum:]_.]*\\)\\)" . 'k-atom-sym-face))
  "Syntax highlighting 0 for `k-mode.'")

(defconst k-font-lock-keywords-1
  (append k-font-lock-keywords-0
          `((,k-const . 'k-const-face)
            (,k-os-dialog . 'k-os-face)
            (,k-system-io . 'k-io-face)
            (,k-cmds . 'k-cmd-face)
            (,k-control . 'k-ctrl-face)
            (,k-system-verbs-nouns . 'k-builtin-face)
            (,k-verbs . 'k-verb-face)))
  "Syntax highlighting 1 for `k-mode.'")

(defvar k-font-lock-keywords
  k-font-lock-keywords-1
  "Default syntax highlighting for `k-mode.'")

(defun k-indent-line ()
  "Default indentation for `k-mode.'"
  (interactive)
  (beginning-of-line)
  (if (bobp) (indent-line-to 0)
    (let ((not-indented t) cur-indent)
      (if (looking-at "[)]})")
          (progn (save-excursion (forward-line -1)
                                 (setq cur-indent (- (current-indentation)
                                                     default-tab-width)))
                 (if (< cur-indent 0) (setq cur-indent 0)))
        (save-excursion (while not-indented
                          (forward-line -1)
                          (if (looking-at "[)]}]")
                              (progn (setq cur-indent (current-indentation))
                                     (setq not-indented nil))
                            (if (looking-at "[([{]")
                                (progn (setq cur-indent (+ (current-indentation)
                                                           default-tab-width))
                                       (setq not-indented-nil))
                              (if (bobp) (setq not-indented nil)))))))
      (if cur-indent (indent-line-to cur-indent) (indent-line-to 0))
      )))

(defvar k-mode-syntax-table (let ((st (make-syntax-table)))
                              (modify-syntax-entry ?_ "w" st) st)
  "Syntax table for `k-mode.'")

(define-derived-mode k-mode fundamental-mode "kx"
  "Major mode for editing k3.3 programs."
  :syntax-table k-mode-syntax-table
  (set (make-local-variable 'font-lock-defaults) '(k-font-lock-keywords))
  ;; (setq-local indent-line-function 'k-indent-line)
  )

(add-to-list 'auto-mode-alist '("\\.k\\'" . k-mode))
(provide 'k-mode)

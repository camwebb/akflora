;; temp mode for file checking

;; 1. Open date file
;; 2. C-x C-f  mode file
;; 3. M-x eval-buffer
;; 4. C-x b  to data
;; 5. M-x datacheck-mode (refreshes too)

(define-generic-mode 'datacheck-mode
  'nil
  '("in" "ex" "et")
  '(
    ("|\\ +[A-Za-zë-]+\\ +[A-Za-zë-]+\\ +\\(\\(subsp.\\|var.\\|f.\\)\\ +[A-Za-zë-]+\\ +\\)?" . 'font-lock-builtin-face)
    ("auct." . 'font-lock-doc-face)
    )
  'nil
  'nil
  "Major mode for data checking")

;; font-lock-warning-face
;; font-lock-function-name-face
;; font-lock-variable-name-face
;; font-lock-keyword-face
;; font-lock-comment-face
;; font-lock-comment-delimiter-face
;; font-lock-type-face
;; font-lock-constant-face
;; font-lock-builtin-face               slate blue
;; font-lock-preprocessor-face
;; font-lock-string-face
;; font-lock-doc-face                   red
;; font-lock-negation-char-face

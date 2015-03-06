;; Time-stamp: <2015-03-05 11:22:46 kmodi>

;; Emacs Lisp Mode

;; Solution to toggle debug on a function whether it is defined inside or
;; outside a `use-package' wrapper
;; http://emacs.stackexchange.com/q/7643/115

;; Edebug defun
(defvar modi/fns-in-edebug nil
  "List of functions for which `edebug' is instrumented.")

(defvar modi/fns-regexp (concat "(\\s-*"
                                "\\(defun\\|defmacro\\)\\s-+"
                                "\\([a-zA-Z0-9\-/]+\\)\\b")
  "Regexp to find defun or defmacro definition.")

(defun modi/toggle-edebug-defun ()
  (interactive)
  (let (fn)
    (save-excursion
      (search-backward-regexp modi/fns-regexp)
      (setq fn (match-string 2))
      (mark-sexp)
      (narrow-to-region (point) (mark))
      (if (member fn modi/fns-in-edebug)
          ;; If the function is already being edebugged, uninstrument it
          (progn
            (setq modi/fns-in-edebug (delete fn modi/fns-in-edebug))
            (eval-region (point) (mark))
            (setq eval-expression-print-length 12)
            (setq eval-expression-print-level  4)
            (message "Edebug disabled: %s" fn))
        ;; If the function is not being edebugged, instrument it
        (progn
          (add-to-list 'modi/fns-in-edebug fn)
          (edebug-defun)
          (setq eval-expression-print-length nil)
          (setq eval-expression-print-level  nil)
          (message "Edebug: %s" fn)))
      (widen))))

;; Debug on entry
(defvar modi/fns-in-debug nil
  "List of functions for which `debug-on-entry' is instrumented.")

(defun modi/toggle-debug-defun ()
  (interactive)
  (let (fn)
    (save-excursion
      (search-backward-regexp modi/fns-regexp)
      (setq fn (match-string 2)))
    (if (member fn modi/fns-in-debug)
        ;; If the function is already being debugged, cancel its debug on entry
        (progn
          (setq modi/fns-in-debug (delete fn modi/fns-in-debug))
          (cancel-debug-on-entry (intern fn))
          (message "Debug-on-entry disabled: %s" fn))
      ;; If the function is not being debugged, debug it on entry
      (progn
        (add-to-list 'modi/fns-in-debug fn)
        (debug-on-entry (intern fn))
        (message "Debug-on-entry: %s" fn)))))

;; Turn on ElDoc mode
(dolist ( hook '(emacs-lisp-mode-hook
                 lisp-interaction-mode-hook
                 ielm-mode-hook
                 eval-expression-minibuffer-setup-hook))
  (add-hook hook #'eldoc-mode))

;; Change the default indentation function for `emacs-lisp-mode' to
;; `common-lisp-indent-function'
;; Improves the indentation of blocks like:
;; (defhydra hydra-rectangle (:body-pre (rectangle-mark-mode 1)
;;                            :color pink
;;                            :post (deactivate-mark))
(add-hook 'emacs-lisp-mode-hook
          (λ (setq-local lisp-indent-function 'common-lisp-indent-function)))


(provide 'setup-elisp)

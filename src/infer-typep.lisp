(in-package :type-i)
;;; typep

(define-inference-rule typep (test)
  (match test
    ((list 'typep '? (list 'quote type))
     (append (mapcar (lambda (type) `(typep ? ',type))
                     (all-compound-types type))
             (if (atom type)
                 (append (predicatep-function type)
                         (predicate-p-function type))
                 (when (every (curry #'eq '*) (cdr type))
                   (append (predicatep-function (car type))
                           (predicate-p-function (car type)))))))))


(defun predicatep (type)
  (let* ((name (symbol-name type)))
    (find-symbol (format nil "~aP" name)
                 (symbol-package type))))

(defun predicate-p (type)
  (let* ((name (symbol-name type)))
    (find-symbol (format nil "~a-P" name)
                 (symbol-package type))))

(defun predicatep-function (type)
  (let ((fnsym (predicatep type)))
    (when (fboundp fnsym)
      `((,fnsym ?)))))

(defun predicate-p-function (type)
  (let ((fnsym (predicate-p type)))
    (when (fboundp fnsym)
      `((,fnsym ?)))))

(defvar *max-compound-type-arguments* 10)
(defvar *compound-infer-level*)
(defun all-compound-types (compound &optional (*compound-infer-level* 0))
  ;; in ANSI, functions like find-type is not implemented.  Also, the
  ;; consequences are undefined if the type-specifier is not a type
  ;; specifier.  however, in most implementations the default behavior is
  ;; to signal an error, verified in CCL and SBCL.
  ;; however, we safeguard with *max-level*. for most types it would be enough :)
  ;; Also, if the type is not valid, it returns nil.
  (unless (< *max-compound-type-arguments* *compound-infer-level*)
    (handler-case
        (progn (typep nil compound)
               (cons compound
                     (all-compound-types
                      (if (consp compound) 
                          `(,@compound *)
                          `(,compound))
                      *compound-infer-level*)))
      (error (c)
        (declare (ignorable c))
        nil))))
;; (all-compound-types '(array))
;; ((ARRAY) (ARRAY *) (ARRAY * *))

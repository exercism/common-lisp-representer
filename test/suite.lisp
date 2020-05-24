(in-package :representer-test)

(def-suite all-tests)
(in-suite all-tests)

(defun run-tests (&optional (suite 'all-tests))
  (run! suite))

(defun equalp++ (x y)
  "EQUALP++ extends EQUALP to include checking uninterned symbols.
Two uninterned symbols are EQUALP++ if their their symbol names are STRING=."
  (flet ((uninterned-symbol-equal (x y)
           (and (symbolp x) (symbolp y)
                (null (symbol-package x)) (null (symbol-package y))
                (string= (symbol-name x) (symbol-name y)))))
    (or (equalp x y)
        (cond ((and (null x) (null y)) t)
              ((or (null x) (null y)) nil)
              ((and (atom x) (atom y)) (uninterned-symbol-equal x y))
              (t (and (equalp++ (car x) (car y))
                      (equalp++ (cdr x) (cdr y))))))))

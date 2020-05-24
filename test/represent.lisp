(in-package #:representer-test)

(def-suite represent-test :in all-tests)
(in-suite represent-test)

(test empty-form
  (is (equalp '(() ())
              (multiple-value-list (representer::represent-toplevel "slug" '())))))

(test arbitrary-form
  (placeholder:init "slug")
  (let ((mapped (placeholder:add 'x))
        (form '(foo 2 x 4)))
    (is (equal (substitute mapped 'x form)
               (representer::represent (car form) form)))))

(test uninterned-symbol-with-no-placeholder
  (is (equalp++ '(:use #:cl)
              (representer::represent :use '(:use #:cl)))))

(test defpackage
  (is (equalp '(((defpackage :test-0
                   (:export :test-1)
                   (:use :cl)))
                ((":TEST-0" . "#:PACK") (":TEST-1" . "#:THINGIE")))
              (multiple-value-list (representer::represent-toplevel
                                    "test"
                                    '((defpackage #:pack
                                        (:use :cl)
                                        (:export #:thingie))))))))

(test defun
  (let ((form
         '(defun foo (bar &key baz &optional (quux 13) &aux extra &rest other)
           (+ bar baz quux extra other))))
    (is (equalp '(((defun :defun-0 (:defun-1
                                    &key :defun-2
                                    &optional (:defun-3 13)
                                    &aux :defun-4
                                    &rest :defun-5)
                     (:docstring nil)
                     ((+ :defun-1 :defun-2 :defun-3 :defun-4 :defun-5))))
                  ((":DEFUN-0" . "FOO") (":DEFUN-1" . "BAR")
                   (":DEFUN-2" . "BAZ") (":DEFUN-3" . "QUUX")
                   (":DEFUN-4" . "EXTRA") (":DEFUN-5" . "OTHER")))
                (multiple-value-list (representer::represent-toplevel
                                      "defun" (list form)))))))

(test defun-with-docstring
  (is (equalp '(:docstring t)
              (fourth (first (representer::represent-toplevel
                              "defun"
                              '((defun foo () "this is a docstring"))))))))

(in-package #:representer-test)

(def-suite represent-test :in all-tests)
(in-suite represent-test)

(def-fixture with-placeholders-initialized (slug)
  (placeholder:init slug)
  (&body)
  (placeholder:init "outside-a-test"))


(test empty-form
  (with-fixture with-placeholders-initialized ("slug")
    (is (equalp '() (representer::represent nil '())))
    (is (equalp '() (placeholder:->alist)))))

(test arbitrary-form
  (with-fixture with-placeholders-initialized ("slug")
    (let ((mapped (placeholder:add 'x))
          (form '(foo 2 x 4)))
      (is (equal (substitute mapped 'x form)
                 (representer::represent (car form) form))))))

(test uninterned-symbol-with-no-placeholder
  (is (equalp++ '(:use #:cl)
              (representer::represent :use '(:use #:cl)))))

(test defpackage
  (with-fixture with-placeholders-initialized ("test")
    (is (equalp '(defpackage :test-0
                  (:export :test-1)
                  (:use :cl))
                (representer::represent 'defpackage
                                        '(defpackage #:pack
                                          (:use :cl)
                                          (:export #:thingie)))))
    (is (equalp '((":TEST-0" . "#:PACK") (":TEST-1" . "#:THINGIE"))
                (placeholder:->alist)))))

(test defun
  (with-fixture with-placeholders-initialized ("defun")
    (is (equalp '(defun :defun-0 (:defun-1
                                  &key :defun-2
                                  &optional (:defun-3 13)
                                  &aux :defun-4
                                  &rest :defun-5)
                  (:docstring nil)
                  ((+ :defun-1 :defun-2 :defun-3 :defun-4 :defun-5)))
                (representer::represent
                 'defun
                 '(defun foo (bar &key baz &optional (quux 13) &aux extra &rest other)
                   (+ bar baz quux extra other)))))
    (is (equal '((":DEFUN-0" . "FOO") (":DEFUN-1" . "BAR")
                 (":DEFUN-2" . "BAZ") (":DEFUN-3" . "QUUX")
                 (":DEFUN-4" . "EXTRA") (":DEFUN-5" . "OTHER"))
               (placeholder:->alist)))))

(test defun-with-docstring
  (with-fixture with-placeholders-initialized ("defun")
    (is (equalp '(:docstring t)
                (fourth (representer::represent
                         'defun
                         '(defun foo () "this is a docstring")))))))

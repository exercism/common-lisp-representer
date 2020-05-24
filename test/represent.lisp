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

(test defpackage
  (is (equalp '(((defpackage :test-0
                   (:export :test-1)
                   (:use :cl)))
                ((":TEST-0" . "#:PACK") (":TEST-1" . "#:THINGIE")
                 (":TEST-2" . "THINGIE")))
              (multiple-value-list (representer::represent-toplevel
                                    "test"
                                    '((defpackage #:pack
                                        (:use :cl)
                                        (:export #:thingie))))))))

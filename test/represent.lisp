(in-package #:representer-test)

(def-suite represent-test :in all-tests)
(in-suite represent-test)

(test empty-form
  (is (equalp '(() ())
              (multiple-value-list (representer::represent-toplevel "slug" '())))))

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

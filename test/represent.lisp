(in-package #:representer-test)

(def-suite represent-test :in all-tests)
(in-suite represent-test)

(test empty-form
  (is (equalp (multiple-value-list (representer::represent-toplevel "slug" '()))
              '(() ()))))

(in-package :representer-test)

(def-suite all-tests)
(in-suite all-tests)

(test empty-solution
  (is (equalp (multiple-value-list (representer::represent '()))
              '(() ()))))

(defun run-tests (&optional (suite 'all-tests))
  (run! suite))

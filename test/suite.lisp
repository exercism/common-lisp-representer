(in-package :representer-test)

(def-suite all-tests)
(in-suite all-tests)

(defun run-tests (&optional (suite 'all-tests))
  (run! suite))

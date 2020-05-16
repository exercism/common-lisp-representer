(in-package :representer-test)

(def-suite all-tests)
(in-suite all-tests)

(test empty-solution
  (is (equal (values '() '()) (representer::represent "empty" '()))))

(test two-fer-example
  (is (equal (uiop:read-file-forms (merge-pathnames "./test/files/twofer.repr"))
             (multiple-value-list
              (representer::represent "twofer"
               (uiop:read-file-forms (merge-pathnames "./test/files/twofer.lisp")))))))

(defun run-tests (&optional (suite 'all-tests))
  (run! suite))

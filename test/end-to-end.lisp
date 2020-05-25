(in-package #:representer-test)

(def-suite end-to-end :in all-tests)
(in-suite end-to-end)

(defun read-test-file (slug type)
  (uiop:read-file-forms (make-pathname :directory '(:relative "test" "files")
                                       :name slug
                                       :type type)))

(test two-fer
  (let* ((slug "two-fer")
         (solution (read-test-file slug "lisp"))
         (expected (read-test-file slug "repr")))
    (placeholder:init slug)
    (let ((actual (list (representer::represent nil solution)
                        (placeholder:->alist))))
      (is (equalp++ expected actual)))))

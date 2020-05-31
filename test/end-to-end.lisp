(in-package #:representer-test)

(def-suite end-to-end :in all-tests)
(in-suite end-to-end)

(defun load-expected-values (directory)
  (let ((repr-file (representer::representation-file directory))
        (mapping-file (representer::mapping-file directory)))
    (values (uiop:read-file-forms repr-file)
            (alexandria:hash-table-plist
             (yason:parse (uiop:read-file-string mapping-file))))))

(defun get-actual-values (slug directory)
  (let ((actual-repr-stream (make-string-output-stream))
        (actual-mapping-stream (make-string-output-stream))
        (solution-file (representer::solution-file slug directory)))

    (with-open-file (solution-stream solution-file :direction :input)
      (representer::produce-representation
       slug solution-stream
       actual-repr-stream actual-mapping-stream))

    (let ((actual-repr-str (get-output-stream-string actual-repr-stream))
          (actual-mapping-str (get-output-stream-string actual-mapping-stream)))
      (values (uiop:slurp-stream-forms
               (make-string-input-stream actual-repr-str))
              (alexandria:hash-table-plist
               (yason:parse actual-mapping-str))))))

(test two-fer
  (let* ((slug "two-fer")
         (directory (make-pathname :directory (list :relative "test" "files" slug))))

    (multiple-value-bind (expected-repr expected-mapping)
        (load-expected-values directory)

      (multiple-value-bind (actual-repr actual-mapping)
          (get-actual-values slug directory)

        (is (equalp++ expected-repr actual-repr))
        (is (equalp++ expected-mapping actual-mapping))))))

(in-package #:representer-test)

(def-suite end-to-end :in all-tests)
(in-suite end-to-end)

(defun load-expected-values (directory)
  (let ((repr-file (representer/main::representation-file directory))
        (mapping-file (representer/main::mapping-file directory)))
    (values (uiop:read-file-forms repr-file)
            (alexandria:hash-table-plist
             (yason:parse (uiop:read-file-string mapping-file))))))

(defun get-actual-values (slug directory)
  (let ((actual-repr-stream (make-string-output-stream))
        (actual-mapping-stream (make-string-output-stream))
        (solution-file (representer/main::solution-file slug directory)))

    (with-open-file (solution-stream solution-file :direction :input)
      (representer/main::produce-representation
       slug solution-stream
       actual-repr-stream actual-mapping-stream))

    (let ((actual-repr-str (get-output-stream-string actual-repr-stream))
          (actual-mapping-str (get-output-stream-string actual-mapping-stream)))
      (values (uiop:slurp-stream-forms
               (make-string-input-stream actual-repr-str))
              (alexandria:hash-table-plist
               (yason:parse actual-mapping-str))))))

(defun end-to-end-test (slug)
  (let ((directory (make-pathname :directory (list :relative "test" "files" slug))))
    (multiple-value-bind (expected-repr expected-mapping)
        (load-expected-values directory)

      (multiple-value-bind (actual-repr actual-mapping)
          (get-actual-values slug directory)

        (is (equalp++ expected-repr actual-repr))
        (is (equalp++ expected-mapping actual-mapping))))))


(test two-fer
  (end-to-end-test "two-fer"))

(test end-of-file (end-to-end-test "end-of-file"))

#-sbcl (format t "~&NO END-TO-END testing for READER-ERROR cases~&")
#+sbcl
(test reader-error
  (end-to-end-test "reader-error")
  (end-to-end-test "sharpsign-dot"))

(in-package #:representer-test)

(def-suite* io-tests :in all-tests)

(test empty-mapping
  (is (string= "{}"
               (with-output-to-string (stream) (io:write-mapping '() stream)))))

(test slurp-solution
  (is (equal '((list 1 2 3))
             (io:slurp-solution (make-string-input-stream "(list 1 2 3)"))))
  (is (equal '((list 1 2 3)
               (list a b c))
             (io:slurp-solution (make-string-input-stream (format nil "~A~&~A"
                                                                  "(list 1 2 3)"
                                                                  "(list a b c)"))))))

(test slurp-solution-invalid-sexpr
  (signals end-of-file
    (io:slurp-solution (make-string-input-stream "(list "))))

(test slurp-solution-reader-error
  (signals reader-error
    (io:slurp-solution (make-string-input-stream "#<foo>"))))

(test slurp-solution-sharpsign-dot
  (signals reader-error
    (io:slurp-solution (make-string-input-stream "#.(+ 1 1)"))))

(test write-circular
  (is (string= "#1=(1 2 . #1#)"
               (with-output-to-string (stream) (io:write-repr '#0=(1 2 . #0#) stream)))))

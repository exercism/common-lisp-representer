(in-package #:representer-test)

(def-suite* io-tests :in all-tests)

(test empty-mapping
  (is (string= "{}"
               (with-output-to-string (stream) (io:write-mapping '() stream)))))

(in-package #:representer/io)

(defun slurp-solution (stream)
  (let ((package-name (package-name *package*)))
    (uiop:with-safe-io-syntax (:package package-name)
      (uiop:slurp-stream-forms stream))))

(defun write-repr (repr stream) (write repr :stream stream))

(defun write-mapping (mapping stream) (yason:encode-alist mapping stream))

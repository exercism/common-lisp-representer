(in-package #:representer/main)

(defun solution-file (slug directory)
  (merge-pathnames (make-pathname :name slug :type "lisp") directory))
(defun representation-file (directory)
  (merge-pathnames (make-pathname :name "representation" :type "txt") directory))
(defun mapping-file (directory)
  (merge-pathnames (make-pathname :name "mapping" :type "json") directory))
(defun repr-package-name (slug) (format nil "~:@(~A~)-REPR" slug))

(defun kill-package (package-name) (ignore-errors (delete-package package-name)))

(defun slurp-solution (stream)
  (let ((package-name (package-name *package*)))
    (uiop:with-safe-io-syntax (:package package-name)
      (uiop:slurp-stream-forms stream))))

(defun write-repr (repr stream) (write repr :stream stream))
(defun write-mapping (mapping stream) (yason:encode-alist mapping stream))

(defun produce-representation (slug
                               solution-stream
                               repr-stream
                               mapping-stream)
  (let ((package-name (repr-package-name slug)))
    (kill-package package-name)
    (unwind-protect
         (let ((*package* (make-package package-name :use '(:cl))))
           (placeholder:init slug)
           (write-repr (represent nil (slurp-solution solution-stream))
                       repr-stream)
           (write-mapping (placeholder:->alist) mapping-stream))
      (kill-package package-name))))


(defun main (&rest args)
  (destructuring-bind ((slug directory)) args
    (with-open-file (solution-stream (solution-file slug directory)
                                     :direction :input)
      (with-open-file (repr-stream (representation-file directory)
                                   :direction :output
                                   :if-exists :supersede)
        (with-open-file (mapping-stream (mapping-file directory)
                                        :direction :output
                                        :if-exists :supersede)
          (produce-representation slug solution-stream repr-stream mapping-stream))))))

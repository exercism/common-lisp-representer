(in-package :representer/main)

(defun solution-file (slug directory)
  (merge-pathnames (make-pathname :name slug :type "lisp")
                   (uiop:ensure-directory-pathname directory)))
(defun representation-file (directory)
  (merge-pathnames (make-pathname :name "representation" :type "txt")
                   (uiop:ensure-directory-pathname directory)))
(defun mapping-file (directory)
  (merge-pathnames (make-pathname :name "mapping" :type "json")
                   (uiop:ensure-directory-pathname directory)))
(defun repr-package-name (slug) (format nil "~:@(~A~)-REPR" slug))

(defun kill-package (package-name) (ignore-errors (delete-package package-name)))

(defun safe-slurp-solution (stream)
  (handler-case
      (io:slurp-solution stream)
    (end-of-file () "End of file due to missing delimiter in solution file.")
    (simple-condition (c) (apply #'format nil
                                 (simple-condition-format-control c)
                                 (simple-condition-format-arguments c)))
    (reader-error (c) (write-to-string c :escape nil))))

(defun produce-representation (slug
                               solution-stream
                               repr-stream
                               mapping-stream)
  (let ((package-name (repr-package-name slug)))
    (kill-package package-name)
    (unwind-protect
         (let ((*package* (make-package package-name :use '(:cl))))
           (placeholder:init slug)
           (io:write-repr (represent nil (safe-slurp-solution solution-stream))
                       repr-stream)
           (io:write-mapping (placeholder:->alist) mapping-stream))
      (kill-package package-name))))


(defun main (&rest args)
  (destructuring-bind (slug input-directory output-directory) args
    (with-open-file (solution-stream (solution-file slug input-directory)
                                     :direction :input)
      (with-open-file (repr-stream (representation-file output-directory)
                                   :direction :output
                                   :if-exists :supersede)
        (with-open-file (mapping-stream (mapping-file output-directory)
                                        :direction :output
                                        :if-exists :supersede)
          (produce-representation slug solution-stream repr-stream mapping-stream))))))

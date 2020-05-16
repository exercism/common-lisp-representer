(in-package #:representer)

(defun slurp-solution (slug directory)
  "Reads in the forms from the file 'SLUG.lisp' in DIRECTORY."
  (uiop:with-safe-io-syntax ()
    (uiop:read-file-forms
     (merge-pathnames (make-pathname :name slug :type "lisp") directory)))  )

(defun write-representation (forms directory)
  "Writes the FORMS to a file 'representation.txt' in the DIRECTORY."
  (let ((output-file (merge-pathnames (make-pathname :name "representation" :type "txt") directory)))
    (with-open-file (output output-file :direction :output :if-exists :supersede)
      (write forms :stream output))))

(defun write-symbol-map (symbol-map directory)
  "Writes SYMBOL-MAP (a list of string typed key-value pairs to a JSON file
'mapping.json' in the DIRECTORY."
  (let ((output-file (merge-pathnames (make-pathname :name "mapping" :type "json") directory)))
    (with-open-file (output output-file :direction :output :if-exists :supersede)
      (st-json:write-json (apply #'st-json:jso symbol-map) output))))

(defun main (args)
  (let ((slug (first args))
        (directory (pathname (second args))))
    (multiple-value-bind (forms symbol-map)
        (represent slug (slurp-solution slug directory))
      (write-representation forms directory)
      (write-symbol-map symbol-map directory))))

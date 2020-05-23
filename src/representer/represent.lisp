(in-package #:representer)

(defun represent-toplevel (slug forms)
  (placeholder:init slug)
  (values (reduce
           #'(lambda (repr form) (append (represent (car form) form) repr))
           forms
           :initial-value (list))
          (placeholder:->alist)))

(defgeneric represent (symbol form))

(defmethod represent (symbol form)
  (declare (ignore symbol))
  form)

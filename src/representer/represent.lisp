(in-package #:representer)

(defun represent (slug forms)
  "Returns normalized FORMS and a symbol map (a list of key-value pairs)"
  (gensym:init-gensym (format nil "~A-" slug))
  (flet ((accumulate (acc form)
           (accumulate-representation
            acc
            (represent-form (car form) form (repr-mapping acc)))))
    (let ((representation
           (reduce #'accumulate forms
                   :initial-value (make-representation))))
      (values (repr-form representation)
              (repr-mapping representation)))))

(defgeneric represent-form (symbol form mapping)
  (:documentation "Produce a representation of FORM based upon SYMBOL. Will not
  modify MAPPING but create new one for returned representation"))

(defmethod represent-form (symbol form mapping)
  (declare (ignore symbol))
  (make-repr form mapping))

(defmethod represent-form ((symbol (eql 'defpackage)) form mapping)
  (let ((orig-package-name (second form))
        (new-package-name (gensym:gensym))
        (options (cddr form))
        (env mapping))
    (setf env (acons new-package-name orig-package-name env))
    (make-repr (append (list symbol new-package-name)
                       (sort (copy-seq options) #'string<
                             :key #'(lambda (f) (symbol-name (car f)))))
               env)))

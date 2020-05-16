(in-package #:representer)

(defun represent (forms)
  "Returns normalized FORMS and a symbol map (a list of key-value pairs)"
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

(defmethod represent-form ((symbol (eql nil)) form mapping)
  (declare (ignore symbol))
  (make-representation form mapping))

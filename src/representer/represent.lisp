(in-package #:representer)

(defun represent (slug forms)
  "Returns normalized FORMS and a symbol map (a list of key-value pairs)"
  (gensym:init-gensym (format nil "~A-" slug))
  (let ((*gensym-counter* 0))
    (flet ((accumulate (acc form)
             (accumulate-representation
              acc
              (represent-form (car form) form (repr-mapping acc)))))
      (let ((representation
             (reduce #'accumulate forms
                     :initial-value (make-representation))))
        (values (repr-form representation)
                (sort (repr-mapping representation)
                      #'string<
                      :key #'(lambda (a) (symbol-name (car a)))))))))

(defgeneric represent-form (symbol form mapping)
  (:documentation "Produce a representation of FORM based upon SYMBOL. Will not
  modify MAPPING but create new one for returned representation"))

(defmethod represent-form (symbol form mapping)
  (declare (ignore symbol))
  (make-repr form mapping))

(defmethod represent-form ((symbol (eql 'defpackage)) form mapping)
  (let* ((orig-package-name (second form))
         (new-package-name (gensym:gensym))
         (exports (find :export (cddr form) :key #'car))
         (other-options (remove :export (cddr form) :key #'car))
         (env (acons new-package-name orig-package-name (list))))
    (let ((export-repr (represent-form (first exports) exports env)))
      (make-repr (append (list symbol new-package-name)
                         (sort (append (list (repr-form export-repr))
                                       other-options)
                               #'string<
                               :key #'(lambda (f) (symbol-name (car f)))))
                 (append (repr-mapping export-repr) mapping)))))

(defmethod represent-form ((symbol (eql :export)) form mapping)
  (let* ((symbols (rest form))
         (env (reduce #'ensure-exists symbols :initial-value mapping)))
    (flet ((lookup (sym) (reverse-lookup sym env sym)))
      (make-repr (cons symbol (mapcar #'lookup symbols))
                 env))))

(defmethod represent-form ((symbol (eql 'in-package)) form mapping)
  (let* ((orig-package-name (second form))
         (new-package-name (reverse-lookup orig-package-name mapping
                                           orig-package-name)))
    (make-repr (list symbol new-package-name) mapping)))

(defun ensure-exists (env symbol)
  (if (not (reverse-lookup symbol env))
      (acons (gensym:gensym) symbol env)
      env))

(defun reverse-lookup (symbol mapping &optional default)
  (or (car (rassoc symbol mapping :key #'symbol-name :test #'string=)) default))

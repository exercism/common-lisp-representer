(in-package #:representer)

(defgeneric represent (symbol form))

(defmethod represent (symbol form)
  (declare (ignore symbol))
  form)

(defmethod represent (symbol (form symbol))
  (declare (ignore symbol))
  (or (placeholder:rassoc form) form))

(defmethod represent (symbol (form list))
  (declare (ignore symbol))
  (mapcar
   #'(lambda (x) (if (atom x)
                (represent nil x)
                (represent (car x) x)))
   form))

(defmethod represent ((symbol (eql 'defpackage)) form)
  (let ((package-name (second form))
        (body (cddr form)))
    `(,symbol ,(placeholder:add package-name)
              ,@(mapcar #'(lambda (f) (represent (car f) f))
                        (sort body
                              #'string<
                              :key #'(lambda (f) (symbol-name (car f))))))))

(defmethod represent ((symbol (eql :export)) form)
  `(,symbol ,@(mapcar #'placeholder:add (rest form))))

(defmethod represent ((symbol (eql :use)) form)
  `(,symbol ,@(mapcar #'placeholder:add (rest form))))

(defmethod represent ((symbol (eql 'defun)) form)
  (declare (ignore symbol))
  (destructuring-bind (symbol name args &body body) form
    `(,symbol ,(placeholder:add name) ,(represent :arglist args)
              ,@(multiple-value-bind (remaining declarations documentation)
                    (alexandria:parse-body body :documentation t)
                  (list (list :docstring (if documentation t nil))
                        (list :declare (mapcar #'(lambda (d) (represent 'declare d))
                                               declarations))
                        (mapcar #'(lambda (f) (represent f f)) remaining))))))

(defmethod represent ((symbol (eql :arglist)) form)
  (declare (ignore symbol))
  (multiple-value-bind (required optional rest keyword allow-other-keys-p aux)
      (alexandria:parse-ordinary-lambda-list form)
    `((:required ,(mapcar #'placeholder:add required))
      (:optional ,(mapcar
                   #'(lambda (opt)
                       (destructuring-bind (name default-value supplied-p) opt
                         (list (placeholder:add name)
                               (placeholder:add default-value)
                               (placeholder:add supplied-p))))
                   optional))
      (:rest ,(placeholder:add rest))
      (:keyword ,(mapcar
                  #'(lambda (key)
                      (destructuring-bind ((keyword name) default-value supplied-p) key
                        (declare (ignore keyword))
                        (list (placeholder:add name)
                              (placeholder:add default-value)
                              (placeholder:add supplied-p))))
                  keyword))
      (:aux ,(mapcar #'(lambda (aux) (list (placeholder:add (first aux))
                                      (placeholder:add (second aux))))
                     aux))
      (:allow-other-keys ,allow-other-keys-p))))

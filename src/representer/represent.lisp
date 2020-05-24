(in-package #:representer)

(defun represent-toplevel (slug forms)
  (placeholder:init slug)
  (values (loop for form in forms collect (represent (car form) form))
          (placeholder:->alist)))

(defgeneric represent (symbol form))

(defmethod represent (symbol form)
  (declare (ignore symbol))
  (mapcar
   #'(lambda (x) (if (atom x)
                (or (and (symbolp x) (placeholder:rassoc x)) x)
                (represent (car x) x)))
   form))

(defmethod represent ((symbol (eql 'defpackage)) form)
  (let ((package-name (second form))
        (body (cddr form)))
    `(,symbol ,(placeholder:add package-name)
              ,@(sort (mapcar #'(lambda (f) (represent (car f) f)) body)
                      #'string<
                      :key #'(lambda (f) (symbol-name (car f)))))))

(defmethod represent ((symbol (eql :export)) form)
  `(,symbol ,@(mapcar #'placeholder:add (rest form))))

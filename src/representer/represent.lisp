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

(defmethod represent ((symbol (eql 'defun)) form)
  (let* ((name (second form))
         (args (third form))
         (docstring (when (stringp (fourth form)) (fourth form)))
         (body (subseq form (if docstring 4 3))))
    `(,symbol ,(placeholder:add name) ,(represent :arglist args)
              (:docstring ,(if docstring t nil))
              ,(represent :body body))))

(defmethod represent ((symbol (eql :arglist)) form)
  (declare (ignore symbol))
  (flet ((add-param (sym)
           (cond ((listp sym) (cons (placeholder:add (car sym)) (cdr sym)))
                 ((char= #\& (char (symbol-name sym) 0)) sym)
                 (t (placeholder:add sym)))))
   (mapcar #'add-param form)))

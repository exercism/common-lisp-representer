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
                     :initial-value (make-repr '() '()))))
        (values (repr-form representation)
                (sort-forms (repr-mapping representation)))))))

(defgeneric represent-form (symbol form mapping)
  (:documentation "Produce a representation of FORM based upon SYMBOL. Will not
  modify MAPPING but create new one for returned representation"))

(defmethod represent-form (symbol form mapping)
  (declare (ignore symbol))
  (reduce #'(lambda (repr form)
              (accumulate-representation
               repr
               (if (atom form) (make-repr (reverse-lookup form (repr-mapping repr) form)
                                          (repr-mapping repr))
                   (represent-form (first form) form (repr-mapping repr)))))
          form
          :initial-value (make-repr (list) mapping)))

(defmethod represent-form ((symbol (eql 'defpackage)) form mapping)
  (let* ((orig-package-name (second form))
         (new-package-name (gensym:gensym))
         (exports (find :export (cddr form) :key #'car))
         (other-options (remove :export (cddr form) :key #'car))
         (env (acons new-package-name orig-package-name (list))))
    (let ((export-repr (represent-form (first exports) exports env)))
      (make-repr (append (list symbol new-package-name)
                         (sort-forms (append (list (repr-form export-repr))
                                             other-options)))
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

(defmethod represent-form ((symbol (eql 'defun)) form mapping)
  (let* ((orig-symbol (second form))
         (new-symbol (reverse-lookup orig-symbol mapping orig-symbol))
         (arglist (canonicalize-arglist (third form)))
         (docstring (when (stringp (fourth form)) (fourth form)))
         (body (subseq form (if docstring 4 3)))
         (arg-list-repr (represent-form :arglist arglist mapping))
         (body-repr (reduce #'(lambda (repr form)
                                (accumulate-representation repr
                                                           (represent-form (first form) form
                                                                           (repr-mapping repr))))
                            body
                            :initial-value (make-repr (list) (repr-mapping arg-list-repr)))))
    (make-repr
     `(,symbol ,new-symbol ,(repr-form arg-list-repr) ,docstring ,@(repr-form body-repr))
     (repr-mapping body-repr))))

(defmethod represent-form ((symbol (eql :arglist)) form mapping)
  (let ((new-mapping (reduce #'(lambda (env item)
                                 (if (atom item)
                                     (ensure-exists env item)
                                     (ensure-exists env (car item))))
                             form
                             :key #'cadr
                             :initial-value mapping)))
    (make-repr (mapcar #'(lambda (item)
                           (if (atom (second item))
                               (list (first item)
                                     (reverse-lookup (second item) new-mapping))
                               (list (first item)
                                     (cons (reverse-lookup (first (second item)) new-mapping)
                                           (rest (second item))))))
                       form)
               new-mapping)))

(defun canonicalize-arglist (arglist)
  (flet ((arglist-keyword-p (item)
           (char= #\& (char (symbol-name item) 0))))
    (let* ((looking-at :required)
           (args (loop for item in arglist
                    if (arglist-keyword-p item) do (setf looking-at item)
                    else  collect (list looking-at item))))
      (sort-forms args))))

(defun ensure-exists (env symbol)
  (let ((found (reverse-lookup symbol env)))
    (if (not found)
        (let ((new-symbol (gensym:gensym)))
          (values (acons (gensym:gensym) symbol env) new-symbol))
        (values env found))))

(defun reverse-lookup (symbol mapping &optional default)
  (or (car (rassoc symbol mapping :test #'string=)) default))

(defun sort-forms (forms)
  (sort (copy-seq forms) #'string< :key #'car))

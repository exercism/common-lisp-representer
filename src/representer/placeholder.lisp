(in-package #:placeholder)

(defvar *placeholders*)
(defvar *slug*)
(defvar *counter*)

(defun init (slug)
  (setf *placeholders* (list)
        *slug* (string-upcase slug)
        *counter* 0))

(defun ->alist ()
  (sort (mapcar
         #'(lambda (acons) (cons (write-to-string (car acons))
                            (write-to-string (cdr acons))))
         *placeholders*)
        #'string<
        :key #'car))

(defun new ()
  (prog1 (intern (format nil "~A-~D" *slug* *counter*) :keyword)
    (incf *counter*)))

(defun add (symbol)
  (if (and symbol (symbolp symbol))
    (let ((existing (rassoc symbol)))
      (or existing
          (let ((new-symbol (new)))
            (setf *placeholders*
                  (acons new-symbol symbol *placeholders*))
            new-symbol)))
    symbol))

(defun assoc (placeholder)
  (cdr (cl:assoc placeholder *placeholders*)))

(defun symbol-equal (&rest symbols)
  (let ((packages (mapcar #'symbol-package symbols)))
    (if (every #'null packages)
        (apply #'string= (mapcar #'symbol-name symbols))
        (apply #'eq symbols))))

(defun rassoc (symbol)
  (car (cl:rassoc symbol *placeholders* :test #'symbol-equal)))

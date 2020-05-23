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
  (let ((existing (rassoc symbol)))
    (or existing
        (let ((new-symbol (new)))
          (setf *placeholders*
                (acons new-symbol symbol *placeholders*))
          new-symbol))))

(defun assoc (placeholder)
  (cdr (cl:assoc placeholder *placeholders*)))

(defun rassoc (symbol)
  (car (cl:rassoc symbol *placeholders*)))

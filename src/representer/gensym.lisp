(in-package #:gensym)

(defvar *gensym-prefix* "G")

(defun init-gensym (prefix &optional (counter 0))
  (setf *gensym-prefix* (string-upcase prefix)
        *gensym-counter* counter))

(defun gensym () (cl:gensym *gensym-prefix*))

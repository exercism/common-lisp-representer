(in-package #:gensym)

(defvar *gensym-prefix* "G")

(defun init-gensym (prefix)
  (setf *gensym-prefix* (string-upcase prefix)))

(defun gensym () (cl:gensym *gensym-prefix*))

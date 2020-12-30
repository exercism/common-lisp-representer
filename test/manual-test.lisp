;;;
;;; Functions useful for doing "one-off" manual testing
;;;

(in-package :representer-test)

(defun represent-stream (solution &optional (slug "test"))
  (let ((repr (make-string-output-stream))
        (map (make-string-output-stream)))
    (unwind-protect
         (progn (representer/main::produce-representation slug solution repr map)
                (pairlis '(:repr :map) (list (get-output-stream-string repr)
                                             (get-output-stream-string map))))
      (progn (close repr)
             (close map)))))

(defun represent-file (solution &optional (slug "test"))
  (with-open-file (stream solution :direction :input)
    (acons :solution solution (represent-stream stream slug))))

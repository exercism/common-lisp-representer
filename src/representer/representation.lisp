(in-package #:representer)

(defstruct (representation (:conc-name repr-))
  (form)
  (mapping))

(defun accumulate-representation (original new)
  "Merges the NEW representation into ORIGINAL one."
  (make-representation (append (repr-form original)
                               (repr-form new))
                       (prune-alist
                        (append (repr-mapping new)
                                (repr-mapping original)))))

(defun prune-alist (alist)
  "Remove duplicate keys found in ALIST"
  (reduce #'(lambda (new key-value)
              (if (assoc (car key-value) new) new
                  (append new (list key-value))))
          alist
          :initial-value (list)))

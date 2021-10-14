(defpackage :placeholder
  (:documentation "Placeholder abstraction. Symbols can be mapped to
  placeholders. Placeholders can be looked up to find symbols and symbols to
  find placeholders. Adding the same symbol multiple times will not result in
  multiple placeholders. The entire mapping can be retrieved in the form of an
  alist.")
  (:use :cl)
  (:shadow :assoc :rassoc)
  (:export :init :assoc :rassoc :->alist :new :add))

(defpackage :representer
  (:use :cl)
  (:export :represent))

(defpackage :representer/io
  (:nicknames :io)
  (:use :cl)
  (:export :slurp-solution :write-repr :write-mapping))

(defpackage :representer/main
  (:use :cl :representer :representer/io)
  (:export :main))

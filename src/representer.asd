(defsystem "representer"
  :name "representer"
  :version "0.0.0"
  :description "Exercism Common Lisp Representer"

  :depends-on ("uiop" "st-json")

  :pathname "representer"
  :serial t
  :components ((:file "packages")
               (:file "representation")
               (:file "represent")
               (:file "main"))

  :in-order-to ((test-op (build-op "representer-test"))))

(defsystem "representer"
  :name "representer"
  :version "0.0.0"
  :description "Exercism Common Lisp Representer"

  :depends-on ("uiop")

  :pathname "representer"
  :serial t
  :components ((:file "packages")
               (:file "main")))

(defsystem "representer-test"
  :name "representer-test"
  :version "0.0.0"
  :description "Automated tests for the Common Lisp Representer"

  :depends-on ("representer" "fiveam")

  :pathname ""
  :serial t
  :components ((:file "packages")
               (:file "suite")
               (:file "placeholder")
               (:file "end-to-end"))

  :build-operation test-op
  :perform (test-op (o c)
                    (declare (ignore o c))
                    (symbol-call :representer-test '#:run-tests)))

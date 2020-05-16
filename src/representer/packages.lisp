(defpackage #:representer
  (:use #:cl)
  (:export #:main))

(defpackage #:gensym
  (:use #:cl)
  (:shadow #:gensym)
  (:export #:gensym #:init-gensym))

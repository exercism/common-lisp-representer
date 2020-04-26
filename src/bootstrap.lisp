(load "quicklisp/setup")

(push (merge-pathnames "src/" *default-pathname-defaults*) asdf:*central-registry*)
(asdf:load-system "representer")

(representer:main (uiop:command-line-arguments))

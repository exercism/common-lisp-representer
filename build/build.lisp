(load "quicklisp/setup")
(ql:quickload "representer")

(sb-ext:save-lisp-and-die "representer"
                          :toplevel #'(lambda ()
                                        (apply #'representer/main:main
                                               (uiop:command-line-arguments)))
                          :executable t)

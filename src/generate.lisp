(load "quicklisp/setup")
(ql:quickload "representer")

(apply #'representer/main:main (uiop:command-line-arguments))

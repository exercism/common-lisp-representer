(load "./src/setup-env")
(asdf:load-system "representer")

(apply #'representer/main:main (uiop:command-line-arguments))

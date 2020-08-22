(load "./src/setup-env")
(asdf:load-system "representer")

(representer/main:main (uiop:command-line-arguments))

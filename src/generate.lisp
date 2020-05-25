(load "./src/setup-env")
(asdf:load-system "representer")

(representer:main (uiop:command-line-arguments))

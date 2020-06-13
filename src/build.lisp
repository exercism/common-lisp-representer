(load "src/setup-env")
(let ((system "representer"))
  (ql:quickload system)
  (asdf:compile-system system))

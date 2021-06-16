(load "quicklisp/setup.lisp")
(ql:quickload "representer")

(let ((bin-dir (make-pathname :directory '(:relative "bin"))))
  (ensure-directories-exist bin-dir)
  (sb-ext:save-lisp-and-die (merge-pathnames "representer" bin-dir)
                            :toplevel #'(lambda ()
                                          (apply #'representer/main:main
                                                 (uiop:command-line-arguments)))
                            :executable t))

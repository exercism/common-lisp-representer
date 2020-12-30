(in-package #:representer-test)

(def-suite represent-test :in all-tests)
(in-suite represent-test)

(def-fixture with-placeholders-initialized (slug)
  (placeholder:init slug)
  (&body)
  (placeholder:init "outside-a-test"))


(test empty-form
  (with-fixture with-placeholders-initialized ("slug")
    (is (equalp '() (representer:represent nil '())))
    (is (equalp '() (placeholder:->alist)))))

(test arbitrary-form
  (with-fixture with-placeholders-initialized ("slug")
    (let ((mapped (placeholder:add 'x))
          (form '(foo 2 x 4)))
      (is (equal (substitute mapped 'x form)
                 (representer:represent (car form) form))))))

(test uninterned-symbol-with-no-placeholder
  (is (equalp++ '(foo #:cl)
                (representer:represent 'foo '(foo #:cl)))))

(test defpackage
  (with-fixture with-placeholders-initialized ("test")
    (is (equalp '(defpackage :test-0
                  (:export :test-1)
                  (:use :test-2))
                (representer:represent 'defpackage
                                        '(defpackage #:pack
                                          (:use :cl)
                                          (:export #:thingie)))))
    (is (equalp '((":TEST-0" . "#:PACK") (":TEST-1" . "#:THINGIE")
                  (":TEST-2" . ":CL"))
                (placeholder:->alist)))))

(test defun-empty
  (with-fixture with-placeholders-initialized ("defun")
    (is (equalp '(defun :defun-0
                  ((:required nil) (:optional nil) (:rest nil) (:keyword nil)
                   (:aux nil) (:allow-other-keys nil))
                  (:docstring nil)
                  (:declare nil)
                  ())
                (representer:represent 'defun '(defun foo ()))))
    (is (equal '((":DEFUN-0" . "FOO"))
               (placeholder:->alist)))))

(test defun-body-is-atom
  (with-fixture with-placeholders-initialized ("defun")
    (is (equalp '(:a-single-atom)
                (sixth (representer:represent 'defun '(defun foo () :a-single-atom)))))))

(test defun-one-of-every-arg
  (with-fixture with-placeholders-initialized ("defun")
    (is (equalp '(defun :defun-0
                  ((:required (:defun-1)) (:optional ((:defun-2 nil nil)))
                   (:rest :defun-3) (:keyword ((:defun-4 nil nil)))
                   (:aux ((:defun-5 nil))) (:allow-other-keys t))
                  (:docstring nil)
                  (:declare nil)
                  ())
                (representer:represent 'defun
                                        '(defun fun (req
                                                     &optional opt
                                                     &rest rest
                                                     &key key
                                                     &allow-other-keys
                                                     &aux aux)))))
    (is (equal '((":DEFUN-0" . "FUN")
                 (":DEFUN-1" . "REQ")
                 (":DEFUN-2" . "OPT")
                 (":DEFUN-3" . "REST")
                 (":DEFUN-4" . "KEY")
                 (":DEFUN-5" . "AUX"))
               (placeholder:->alist)))))

(test defun-with-default-values-and-supplied-p
  (with-fixture with-placeholders-initialized ("defun")
    (let ((representation
           (representer:represent
            'defun
            '(defun foo (&optional (opt opt-default opt-supplied-p)
                         &key (key key-default key-supplied-p))))))
      (is (equal '(:optional ((:defun-1 :defun-2 :defun-3)))
                 (assoc :optional (third representation))))
      (is (equal '(:keyword ((:defun-4 :defun-5 :defun-6)))
                 (assoc :keyword (third representation))))
      (is (equal '((":DEFUN-0" . "FOO")
                   (":DEFUN-1" . "OPT")
                   (":DEFUN-2" . "OPT-DEFAULT")
                   (":DEFUN-3" . "OPT-SUPPLIED-P")
                   (":DEFUN-4" . "KEY")
                   (":DEFUN-5" . "KEY-DEFAULT")
                   (":DEFUN-6" . "KEY-SUPPLIED-P"))
                 (placeholder:->alist))))))

(test defun-with-aux-value
  (with-fixture with-placeholders-initialized ("defun")
    (let ((representation
           (representer:represent
            'defun
            '(defun foo (&aux (aux aux-default))))))
      (is (equal '(:aux ((:defun-1 :defun-2)))
                 (assoc :aux (third representation))))
      (is (equal '((":DEFUN-0" . "FOO")
                   (":DEFUN-1" . "AUX")
                   (":DEFUN-2" . "AUX-DEFAULT"))
                 (placeholder:->alist))))))


(test defun-with-docstring
  (with-fixture with-placeholders-initialized ("defun")
    (is (equalp '(defun :defun-0 ((:required nil) (:optional nil)
                                  (:rest nil) (:keyword nil)
                                  (:aux nil) (:allow-other-keys nil))
                  (:docstring t)
                  (:declare nil)
                  (()))
                (representer:represent 'defun '(defun foo () "a docstring" nil))))
    (is (equal '((":DEFUN-0" . "FOO"))
               (placeholder:->alist)))))

(test defun-with-declarations
  (with-fixture with-placeholders-initialized ("defun")
    (is (equalp '(:declare ((declare (ignore :defun-1) (speed 0))))
                (fifth (representer:represent
                        'defun '(defun foo (bar)
                                 (declare (ignore bar) (speed 0)))))))
    (is (equalp '(:declare ((declare (ignore :defun-1))
                           (declare (speed 0))))
                (fifth (representer:represent
                        'defun '(defun foo (bar)
                                 (declare (ignore bar))
                                 (declare (speed 0)))))))))

(test defun-represents-body
  (with-fixture with-placeholders-initialized ("defun")
    (is (equalp '((list :DEFUN-1 :DEFUN-2))
                (sixth (representer:represent
                        'defun '(defun foo (a b) (list a b))))))))

(test dotted-pair
  ;; quote here used as example symbol...
  (with-fixture with-placeholders-initialized ("dotted-pair")
    (is (equalp '(QUOTE (1 2 . 3))
                (representer:represent 'quote '(quote (1 2 . 3)))))))

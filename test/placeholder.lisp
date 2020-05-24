(in-package :representer-test)

(def-suite placeholder-tests :in all-tests)
(in-suite placeholder-tests)

(defun test-cleanup () (placeholder:init "outside-of-a-test"))

(def-fixture init-with-slug (slug)
  (placeholder:init slug)
  (&body)
  (test-cleanup))

(test starting-conditions
  (with-fixture init-with-slug ("slug")
    (is (equal (placeholder:->alist) (list)))
    (is (equal (placeholder:new) :slug-0))
    (is (equal (placeholder:new) :slug-1))
    (is (null (placeholder:assoc :slug-0)))
    (is (null (placeholder:rassoc 'some-symbol)))))

(test adding-a-mapping
  (with-fixture init-with-slug ("mapping")
    (let* ((symbol 'a-symbol)
           (mapped (placeholder:add symbol))
           (lookup (placeholder:assoc mapped))
           (rev-lookup (placeholder:rassoc symbol)))
      (is (eq lookup symbol)
          "lookup of '~A' resulted in '~A' not '~A'" mapped lookup symbol)
      (is (eq rev-lookup mapped)
          "reverse lookup of '~A' result in '~A' not '~A'" symbol rev-lookup mapped)
      (is (equal (placeholder:->alist) `((,(write-to-string mapped) .
                                           ,(write-to-string symbol))))))))

(test rassoc-of-uninterned-symbol
  (with-fixture init-with-slug ("uninterned")
    (let ((mapped (placeholder:add '#:foo)))
      (is (eq mapped (placeholder:rassoc '#:foo))))))

(def-fixture init-with-existing-symbols (slug symbols)
  (placeholder:init slug)
  (dolist (sym symbols) (placeholder:add sym))
  (&body)
  (test-cleanup))

(test adding-already-existing-symbol
  (let ((existing-symbols '(:foo :bar)))
    (with-fixture init-with-existing-symbols ("mapping" existing-symbols)
      (is (= #1=(length (placeholder:->alist)) #2= (length existing-symbols))
          "length should still be ~D not ~D" #2# #1#)

      (let ((existing-placeholder (placeholder:rassoc :foo))
            (add-result (placeholder:add :foo)))
        (is (eq add-result  existing-placeholder)
            "result of add should have been '~A' not '~A'"
            existing-placeholder add-result)))))

(test alist-always-sorted-by-placeholder
  (with-fixture init-with-slug ("someslug")
    (let* ((symbol1 'one)
           (symbol2 'two)
           (symbol3 'three)
           (first-mapping (placeholder:add symbol1))
           (second-mapping (placeholder:add symbol2))
           (third-mapping (placeholder:add symbol3))

           (expected-alist `((,(write-to-string first-mapping) .
                               ,(write-to-string symbol1))
                             (,(write-to-string second-mapping) .
                               ,(write-to-string symbol2))
                             (,(write-to-string third-mapping) .
                               ,(write-to-string symbol3)))))
      (is (equal (placeholder:->alist) expected-alist))

      ;; add symbol2 again!
      (placeholder:add symbol2)
      (is (equal (placeholder:->alist) expected-alist)
          "alist should still be in correct order after adding symbol again (was ~A)"
          (placeholder:->alist)))))

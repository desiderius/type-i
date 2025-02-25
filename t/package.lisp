#|
  This file is a part of type-i project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage :type-i.test
  (:use :cl :type-i :fiveam :alexandria))
(in-package :type-i.test)

(def-suite :type-i)
(in-suite :type-i)

(defun subset (expected actual)
  (subsetp expected actual :test #'equal))

(test test-type
  (is (type= nil (test-type '(ababa ?))))
  (is (type= 'null (test-type '(eql nil ?))))
  (is (type= 'string (test-type '(stringp ?))))

  ;; okay when the test is initially typep
  (is (type= 'string (test-type '(typep ? 'string))))

  (is-false (member '(eql t) (type-tests t) :test #'equal))

  (is (type= t (test-type t)))


  (is (subset '((typep ? 'fixnum)) (type-tests 'fixnum)))

  (is (subset '((typep ? 'integer)
                (integerp ?))
              (type-tests 'integer)))

  ;; more inference on integers, e.g., (< 0 ? 4), should be added
  (is (subset '((typep ? '(mod 5))
                (typep ? '(integer 0 4)))
              (type-tests '(mod 5))))
  (is (not (subset '((integerp ?))
                   (type-tests '(mod 5)))))

  (is (type= '(integer 0 5)
             (test-type '(< 0 ? 5))))
  (is (type= '(rational 0 5/2)
             (test-type '(< 0 ? 5/2))))
  (is (type= '(single-float 0.0 5.0)
             (test-type '(< 0.0 ? 5.0))))
  (is (type= '(double-float 0.0d0 5.0d0)
             (test-type '(< 0.0d0 ? 5.0d0))))
  (is (type= '(float 0.0 5.0d0)
             (test-type '(< 0.0 ? 5.0d0))))
  (is (type= '(real 0.0 5)
             (test-type '(< 0.0 ? 5))))
  )

(eval-when (:load-toplevel :execute)
  (run! :type-i))


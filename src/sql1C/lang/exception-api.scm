; This program and the accompanying materials are made available under the
; terms of the MIT license (X11 license) which accompanies this distribution.

; Author: C. Bürger

#!r6rs

(library
 (sql1C exception-api)
 (export
  throw-racrSQL-exception
  siple-exception?)
 (import
  (rnrs))
 
 (define-condition-type racrSQL-exception
   &violation
   make-siple-exception
   siple-exception?)
 
 (define throw-racrSQL-exception
   (lambda (message)
     (raise-continuable
      (condition
       (make-siple-exception)
       (make-message-condition message))))))
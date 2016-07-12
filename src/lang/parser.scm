#!r6rs
; Лексер для языка запросов

(library
 (sql1C lexer)
 (export token-line token-column token-type token-value construct-lexer only-id! get-keyword-symbol)
 (import (rnrs)
         (sql1C exception-api)
         (sql1C lexer)
         )
 
 
 
(define lex->list
  (lambda (s)
    (only-id! #f)
    (let* ([buf (open-string-input-port (string-append s " "))]
           [lexer (construct-lexer buf )])
      (let loop ((results '()))
        (let ((next-token   (lexer)))
          (if (eq? (eof-object) (token-type next-token))
              (reverse (cons  (list (token-type next-token) (token-value next-token)) results))
              (loop (cons  (list (token-type next-token) (token-value next-token)) results))))))))

 
 (define-record-type token
   (fields ws0 lxm ws1))
 
 (define-record-type Packet
   (fields RootList))
 
 
 (define construct-parser
   (lambda (lexer)
     (letrec (


               (line 1)
               (column 0)
               (current-token (lexer))
               (read-next-token
                (lambda ()
                  (let ((old-token current-token))
                    (set! current-token (lexer))
                    (set! line (token-line old-token))
                    (set! column (token-column old-token))
                    (token-value old-token))))
               (match-token?
                (lambda (to-match)
                  (eq? (token-type current-token) to-match)))
               (match-token!
                (lambda (to-consume error-message)
                  (if (match-token? to-consume)
                      (read-next-token)
                      (parser-error error-message))))
               (parser-error
                (lambda (message)
                  (throw-racrSQL-exception ; Abort parsing with error message
                   (string-append
                    "Parser Error ("
                    (number->string line)
                    ","
                    (number->string column)
                    ";["
                    (token-value current-token)
                    "]): "
                    message))))
               

              
              (parse-Packet
               (lambda ()
                 (let loop ((decls (list)))
                   (if (match-token? (eof-object))
                       (list 'CompilationUnit (list  (reverse decls)))
                       (loop (cons (parse-Root) decls))))))
              (parse-Root
               (lambda ()
                 (or (parse-DropCommand) (parse-SelectCommand))))

              (parse-DropCommand
               (lambda ()
                 (if (match-token? 'lxmDROP)
                     (list 'DropCommand (match-token! 'lxmDROP "") (match-token! 'tknID ""))
                     #f)))

              (parse-SelectCommand
               (lambda ()
                 (if (match-token? 'lxmDROP)
                     (list 'DropCommand (match-token! 'lxmDROP "") (match-token! 'tknID ""))
                     #f)))



              ) ;; end
       
              
       (lambda ()
         (let ((ast (parse-Packet)))
           ast)))))
 
 
 
 
 ;(define res ((construct-parser  (construct-lexer  (open-string-input-port
;"Select 1;
;Select 2;
;Select 3")))))

 ((construct-parser  (construct-lexer  (open-string-input-port "drop data "))))
 )
 
 
 
 
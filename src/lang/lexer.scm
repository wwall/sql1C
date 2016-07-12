#!r6rs
; Лексер для языка запросов

(library
 (sql1C lexer)
 (export token-line token-column token-type token-value construct-lexer only-id! get-keyword-symbol)
 (import (rnrs)
         (sql1C exception-api)
         )
 
 (define-record-type token
   (fields  line column type value))
 
 
 
 
 
 (define only-id #f)
 
 (define hash-keyword (make-hashtable (lambda (x) (string-hash x)) (lambda (x y) (equal? x y))))
 
 (define KeywordList '( 
                       ("ALL" "ВСЕ" lxmALL)
                       ("ALLOWED" "РАЗРЕШЕННЫЕ" lxmALLOWED)
                       ("AND" "И" lxmAND)
                       ("AS" "КАК" lxmAS)
                       ("ASC" "ВОЗР" lxmASC)
                       ("AVG" "СРЕДНЕЕ" lxmAVG)
                       ("AUTOORDER" "АВТОУПОРЯДОЧИВАНИЕ" lxmAUTOORDER)
                       ("BEGINOFPERIOD" "НАЧАЛОПЕРИОДА" lxmBEGINOFPERIOD)
                       ("BETWEEN" "МЕЖДУ" lxmBETWEEN)
                       ("BOOLEAN" "БУЛЕВО" lxmBOOLEAN)
                       ("CASE" "ВЫБОР" lxmCASE)
                       ("CAST" "ВЫРАЗИТЬ" lxmCAST)
                       ("COUNT" "КОЛИЧЕСТВО" lxmCOUNT)
                       ("DATE" "ДАТА" lxmDATE)
                       ("DATEADD" "ДОБАВИТЬКДАТЕ" lxmDATEADD)
                       ("DATEDIFF" "РАЗНОСТЬДАТ" lxmDATEDIFF)
                       ("DATETIME" "ДАТАВРЕМЯ" lxmDATETIME)
                       ("DAY" "ДЕНЬ" lxmDAY)
                       ("DAYOFWEEK" "ДЕНЬНЕДЕЛИ" lxmDAYOFWEEK)
                       ("DAYOFYEAR" "ДЕНЬГОДА" lxmDAYOFYEAR)
                       ("DESC" "УБЫВ" lxmDESC)
                       ("DISTINCT" "РАЗЛИЧНЫЕ" lxmDISTINCT)
                       ("DROP" "УНИЧТОЖИТЬ" lxmDROP)
                       ("ELSE" "ИНАЧЕ" lxmELSE)
                       ("END" "КОНЕЦ" lxmEND)
                       ("ENDOFPERIOD" "КОНЕЦПЕРИОДА" lxmENDOFPERIOD)
                       ("ESCAPE" "СПЕЦСИМВОЛ" lxmESCAPE)
                       ("FALSE" "ЛОЖЬ" lxmFALSE)
                       ("FOR" "ДЛЯ" lxmFOR)
                       ("FROM" "ИЗ" lxmFROM)
                       ("FULL" "ПОЛНОЕ" lxmFULL)
                       ("GROUP" "СГРУППИРОВАТЬ" lxmGROUP)
                       ("HAVING" "ИМЕЮЩИЕ" lxmHAVING)
                       ("HIERARCHY" "HIERARCHY" lxmHIERARCHY)
                       ("ИЕРАРХИИ" "ИЕРАРХИИ" lxmHIERARCHYIN)
                       ("ИЕРАРХИЯ" "ИЕРАРХИЯ" lxmHIERARCHYON)
                       ("HOUR" "ЧАС" lxmHOUR)
                       ("IN" "В" lxmIN)
                       ("INDEX" "ИНДЕКСИРОВАТЬ" lxmINDEX)
                       ("INNER" "ВНУТРЕННЕЕ" lxmINNER)
                       ("INTO" "ПОМЕСТИТЬ" lxmINTO)
                       ("IS" "ЕСТЬ" lxmIS)
                       ("ISNULL" "ЕСТЬNULL" lxmISNULL)
                       ("JOIN" "СОЕДИНЕНИЕ" lxmJOIN)
                       ("LEFT" "ЛЕВОЕ" lxmLEFT)
                       ("LIKE" "ПОДОБНО" lxmLIKE)
                       ("MAX" "МАКСИМУМ" lxmMAX)
                       ("VALUE" "ЗНАЧЕНИЕ" lxmVALUE)
                       ("MIN" "МИНИМУМ" lxmMIN)
                       ("MINUTE" "МИНУТА" lxmMINUTE)
                       ("MONTH" "МЕСЯЦ" lxmMONTH)
                       ("NOT" "НЕ" lxmNOT)
                       ("NULL" "NULL" lxmNULL)
                       ("NUMBER" "ЧИСЛО" lxmNUMBERTYPE)
                       ("BY" "ПО" lxmBY)
                       ("ON" "ПО" lxmON)
                       ("ONLY" "ТОЛЬКО" lxmONLY)
                       ("OR" "ИЛИ" lxmOR)
                       ("ORDER" "УПОРЯДОЧИТЬ" lxmORDER)
                       ("OUTER" "ВНЕШНЕЕ" lxmOUTER)
                       ("PERIODS" "ПЕРИОДАМИ" lxmPERIODS)
                       ("PRESENTATION" "ПРЕДСТАВЛЕНИЕ" lxmPRESENTATION)
                       ("PRESENTATIONREFS" "ПРЕДСТАВЛЕНИЕССЫЛКИ" lxmPRESENTATIONREFS)
                       ("QUARTER" "КВАРТАЛ" lxmQUARTER)
                       ("REFS" "ССЫЛКА" lxmREFS)
                       ("RIGHT" "ПРАВОЕ" lxmRIGHT)
                       ("SECOND" "СЕКУНДА" lxmSECOND)
                       ("SELECT" "ВЫБРАТЬ" lxmSELECT)
                       ("STRING" "СТРОКА" lxmSTRING)
                       ("SUBSTRING" "ПОДСТРОКА" lxmSUBSTRING)
                       ("SUM" "СУММА" lxmSUM)
                       ("TABLE" "ТАБЛИЦА" lxmTABLE)
                       ("THEN" "ТОГДА" lxmTHEN)
                       ("TOP" "ПЕРВЫЕ" lxmTOP)
                       ("TOTALS" "ИТОГИ" lxmTOTALS)
                       ("TRUE" "ИСТИНА" lxmTRUE)
                       ("TYPE" "ТИП" lxmTYPE)
                       ("UNDEFINED" "НЕОПРЕДЕЛЕНО" lxmUNDEFINED)
                       ("UNION" "ОБЪЕДИНИТЬ" lxmUNION)
                       ("UPDATE" "ИЗМЕНЕНИЯ" lxmUPDATE)
                       ("VALUETYPE" "ТИПЗНАЧЕНИЯ" lxmVALUETYPE)
                       ("WEEK" "НЕДЕЛЯ" lxmWEEK)
                       ("WHEN" "КОГДА" lxmWHEN)
                       ("WHERE" "ГДЕ" lxmWHERE)
                       ("YEAR" "ГОД" lxmYEAR)))
 
 
 (define (get-keyword-symbol lexeme what)
   (define (keyword-symbol upcase-lexeme what)
     (hashtable-ref hash-keyword upcase-lexeme what))
   (if only-id
       what
       (keyword-symbol (string-upcase lexeme) what)))
 
 (define (only-id! x)
   (set! only-id x))
 
 
 (define construct-lexer
   (lambda (input-port source)
     (letrec (;;; Lexer IO support functions:
              (line-position 1)
              (column-position 1)
              (my-read-char
               (lambda ()
                 (let ((c (get-char input-port )))
                   (cond
                     ((eof-object? c)
                      c)
                     ((char=? c #\newline)
                      (set! line-position (+ line-position 1))
                      (set! column-position 1)
                      c)
                     (else
                      (set! column-position (+ column-position 1))
                      c)))))
              (my-peek-char
               (lambda () (lookahead-char input-port)))
              (lexer-error
               (lambda (message character)
                 (throw-racrSQL-exception ; Abort lexing with error message
                  (string-append "Lexer Error (" (number->string line-position) "," (number->string column-position) ";[" (string character) "]): " message))))
              (new-token
               (lambda (type value)
                 (begin
                   (only-id! (or (eq? type 'lxmDOT) (eq? type 'lxmAS)))
                   (make-token  line-position (- column-position (string-length value)) type value))))
              ;;; Complicated token processing functions:
              (is-whitespace
               (lambda (c)
                 (or (char=? c #\space)
                     (char=? c #\newline)
                     (char=? c (integer->char #x000D)) ; Carriage return
                     (char=? c #\tab)
                     (char=? c (integer->char #x0008)) ; Backspace
                     (char=? c (integer->char #x000C))))) ; Formfeed
              (read-integer ; Read sequence of digits
               (lambda (n)
                 (let ((c (my-peek-char)))
                   (if (char-numeric? c)
                       (read-integer (cons (my-read-char) n))
                       (apply string (reverse n))))))
              (read-number ; Read integer or real
               (lambda (n)
                 (let ((integer-part (read-integer n)))
                   (if (char=? (my-peek-char) #\.)
                       (begin
                         (my-read-char) ; Consume the "."
                         (let ((c (my-read-char)))
                           (if (not (char-numeric? c))
                               (lexer-error "Invalid number. Real numbers must have a decimal place." c)
                               (string-append integer-part (string #\.) (read-integer (list c))))))
                       integer-part))))
              (read-identifier ; Read sequence of letters and digits
               (lambda (id)
                 (let ((c (my-peek-char)))
                   (if (or (char-alphabetic? c) (char-numeric? c) (eq? c #\_))
                       (read-identifier (cons (my-read-char) id))
                       (apply string (reverse id))))))
              (read-string ; Read a string's content
               (lambda (str)
                 (let ((c (my-peek-char)))
                   (if (not (char=? c #\"))
                       (read-string (cons (my-read-char) str))
                       (let ([was (my-read-char)])
                         (if (char=? (my-peek-char) #\")
                             (read-string (cons was (cons (my-read-char) str)))
                             (apply string (reverse str))))))))
              )
       
       ;;; Return lexer function:
       (lambda ()
         (let recognize-token ((c (my-read-char)))
           
           (cond
             ((eqv? (eof-object) c)
              (new-token c ""))
             ((is-whitespace c)
              (recognize-token (my-read-char)))
             
             ((or (eq? c #\_) (char-alphabetic? c))
              (let ((id (read-identifier (list c))))
                (new-token (get-keyword-symbol id 'tknID) id)))
             ((char-numeric? c)
              (new-token 'tknNUMBER (read-number (list c))))
             ((char=? c #\")
              (let ((content (read-string (list))))
                (new-token 'tknSTRING content)))
             ((char=? c #\.)
              (new-token 'lxmDOT "."))
             ((char=? c #\,)
              (new-token 'lxmCOMMA ","))
             ((char=? c #\;)
              (new-token 'lxmSEMI ";"))
             ((char=? c #\()
              (new-token 'lxmOPEN "("))
             ((char=? c #\))
              (new-token 'lxmCLOSE ")"))
             ((char=? c #\+)
              (new-token 'lxmPLUS "+"))
             ((char=? c #\-)
              (new-token 'lxmMINUS "-"))
             ((char=? c #\*)
              (new-token 'lxmMUL "*"))
             ((char=? c #\/)
              (if (char=? #\/ (my-peek-char))
                  (let consume-one-line-comment ()
                    (if (not (char=? (my-peek-char) #\newline))
                        (begin
                          (my-read-char)
                          (if (not (eof-object? (my-peek-char)))
                              (consume-one-line-comment)
                              (recognize-token (my-read-char))))
                        (recognize-token (my-read-char))))
                  (new-token 'lxmDIV "/")))
             ((char=? c #\=)
              (new-token 'lxmEQU "="))
             ((char=? c #\<)
              (cond 
                ((char=? (my-peek-char) #\=)
                 (begin
                   (my-read-char) ; Consume the "="
                   (new-token 'lxmLT-EQU "<=")))
                ((char=? (my-peek-char) #\>)
                 (begin
                   (my-read-char) ; Consume the ">"
                   (new-token 'lxmNOT-EQU "<>")))
                (#t (new-token 'lxmLT "<"))))
             ((char=? c #\>)
              (if (char=? (my-peek-char) #\=)
                  (begin
                    (my-read-char) ; Consume the "="
                    (new-token 'lxmGT-EQU ">="))
                  (new-token 'lxmGT ">")))
             (else
              (lexer-error "Illegal character." c))))))))
 
 
 
 (begin
   (map  (lambda (x)
           (hashtable-set! hash-keyword (car x  ) (caddr x))
           (hashtable-set! hash-keyword (cadr x ) (caddr x))) KeywordList))
 )
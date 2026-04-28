#lang racket
(module+ test
  (require rackunit))

(require racket/match)

;fact
(define wme (box
              (list
                '(Person (name taro) (age 30))
                '(Order (name taro) (item book))
                '(Person (name hanako) (age 10)))))

(define (facts)
  (unbox wme))

;; Alpha node
(define (match? fact cnd)
  (match* (fact cnd)
    [(`(Person (name ,a) (age ,b)) '(type Person)) #t]
    [(`(Person (name ,a) (age ,b)) `(age = ,n)) 
     (= b n)]
    [(`(Person (name ,a) (age ,b)) `(age > ,n)) 
     (> b n)]
    [(`(Person (name ,a) (age ,b)) `(age < ,n)) 
     (< b n)]
    [(`(Order (name ,a) (item ,b)) '(type Order)) #t]
    [(_ _) #f]))

(define (alpha-filter cnd)
  (filter (λ (f) (match? f cnd)) (facts)))

(define (:name l)
  (second (second l)))

;; Beta node
(define (join left right)
  (for*/list ([l left]
              [r right]
              #:when (equal? (:name l)
                             (:name r)))
    (list l r)))

(define (exec results)
  (let loop ((x results))
    (cond ((null? x) (newline))
          (else
            (match (second (car x))
              [`(Order (name ,a) (item ,b)) 
                (begin 
                  (displayln (format "~a order a ~a." a b))
                  (loop (cdr x)))]
              [_ (displayln "Unknow")])))))

(define (find cnd1 cnd2)
  (let ((alpha1 (alpha-filter cnd1))
        (alpha2 (alpha-filter cnd2)))
    (join alpha1 alpha2)))

(define-syntax query
  (syntax-rules (age type)
    [(rule (age op x)
           (type t))
     (find '(age op x) '(type t))]))

(module+ test
  ;; Any code in this `test` submodule runs when this file is run using DrRacket
  ;; or with `raco test`. The code here does not run when this file is
  ;; required by another module.

  (check-equal? (match? '(hello) '(hello)) #f)
  (check-equal? (match? '(Person (name a) (age 30)) '(type Person)) #t)
  (check-equal? (match? '(Person (name a) (age 30)) '(age > 20)) #t)
  (check-equal? (match? '(Person (name a) (age 30)) '(age > 60)) #f)

)
(module+ main
  ;; (Optional) main submodule. Put code here if you need it to be executed when
  ;; this file is run using DrRacket or the `racket` executable.  The code here
  ;; does not run when this file is required by another module. Documentation:
  ;; http://docs.racket-lang.org/guide/Module_Syntax.html#%28part._main-and-test%29

  (exec 
    (query (age = 30)
           (type Order)))

)


(import (chicken io)
        (chicken process))

(define (run-computer)
  (process* "../intcode-machine" '("input")))

(define (get-amplifier-signal phase-setting input)
  (let-values
    (((computer-out computer-in computer-pid computer-err) (run-computer)))

    (write-line (number->string phase-setting) computer-in)
    (write-line (number->string input) computer-in)

    (process-wait computer-pid)
    (read computer-out)))

(define (get-amplifier-sequence-signal sequence)
  (let next ((phase-settings sequence)
             (input 0))
    (print* sequence " " input "\r")

    (if (null? phase-settings) input
        (next (cdr phase-settings)
              (get-amplifier-signal (car phase-settings) input)))))

(define (remove-once number numbers)
  (cond
    ((null? numbers)
     '())
    ((= number (car numbers))
     (cdr numbers))
    (else
      (cons (car numbers)
            (remove-once number (cdr numbers))))))

(define (permute numbers)
  (let* ((with-first-element
           (lambda (element)
             (lambda (some-list)
               (cons element some-list))))
         (permutations-with-x-first
           (lambda (numbers)
             (lambda (x)
               (map (with-first-element x)
                    (permute (remove-once x numbers)))))))

    (if (= (length numbers) 1) (list numbers)
        (apply append
               (map (permutations-with-x-first numbers) numbers)))))

(permute '(1 2 3))

(print "\rMaximum signal: "
  (let find-best ((candidates (permute '(0 1 2 3 4)))
                  (best-so-far -1))
    (if (null? candidates) best-so-far
        (let ((current-signal (get-amplifier-sequence-signal (car candidates))))
          (find-best (cdr candidates)
            (max current-signal best-so-far))))))
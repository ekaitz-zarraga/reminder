;; Copyright 2024 Ekaitz Zarraga <ekaitz@elenq.tech>
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

(define-module (reminder)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 getopt-long)
  #:use-module (notify)
  #:use-module (notify glib))

(define version "0.0.1")

(define help
"~a: Daemon that will trigger a desktop notification with the configured\
period reminding you something.

USAGE:
\tguile -e '(reminder)' -c configuration.scm

Example configuration file

  ((period 45)  ;; In minutes, how much time to period between notifications
   (title \"Crush it!\")     ;; Notification title (optional)
   (messages  (\"Squats x 20\"    ;; Some text with each message to show
               \"Push-ups x 15\"  ;; Accepts simple markup like <i> <b>
               \"Pull-ups x 6\"
               \"Kettlebell swings x 30\")))

The daemon will rotate through the provided message list.~%
")

(define (read-configuration filename)
  (let* ((data (call-with-input-file filename read))
         (period (assoc 'period data))
         (title (assoc 'title data))
         (messages (assoc 'messages data)))
    (unless period (error "No `period` given in config"))
    (unless messages (error "No `messages` list given in config"))
    (list (* 60 (cadr period))
          (if title (cadr title) "Remember!")
          (apply circular-list (cadr messages)))))

(define (notification-loop period title messages)
  (notify-init #:app-name "message-notifier") ;; Dynamic wind?
  (let loop ((messages messages))
    (let* ((message (car messages))
           (noti (notification-new title #:body message)))
    (notification-show noti))
    (sleep period)
    (loop (cdr messages)))
  (notify-uninit))

(define (main args)
  (define progname "reminder.scm")
  (define option-spec
    '((config  (single-char #\c) (value #t))
      (version (single-char #\v) (value #f))
      (help    (single-char #\h) (value #f))))
  (let* ((options (getopt-long args option-spec)))
    (when (option-ref options 'help #f)
      (format #t help progname)
      (exit 0))
    (when (option-ref options 'version #f)
      (format #t "~a: ~a~%" progname version)
      (exit 0))
    (unless (option-ref options 'config #f)
      (format #t "~a: No configuration provided~%" progname)
      (exit 1))

    (let ((config (read-configuration (option-ref options 'config #f))))
      (apply notification-loop config))))

(main (command-line))

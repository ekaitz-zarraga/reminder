# Reminder

Daemon that will trigger a desktop notification with the configured period
reminding you something.

Call it in the command line:

``` bash
guile -L . -e '(reminder)' -- -c config.scm
```

Example configuration file:

``` scheme
  ((period 45)  ;; In minutes, how much time to period between notifications
   (title "Crush it!")     ;; Notification title (optional)
   (messages  ("Squats x 20"    ;; Some text with each message to show
               "Push-ups x 15"  ;; Accepts simple markup like <i> <b>
               "Pull-ups x 6"
               "Kettlebell swings x 30")))
```

The daemon will rotate through the provided message list.

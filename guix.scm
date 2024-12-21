(use-modules (guix gexp)
             (guix packages)
             (guix git-download)
             ((guix licenses) #:prefix license:)
             (guix build-system guile)
             ((guix build utils) #:select (with-directory-excursion))
             (gnu packages)
             (gnu packages guile)
             (gnu packages guile-xyz))


(define %source-dir (dirname (current-filename)))

(package
  (name "reminder")
  (version "0.0.1")
  (source (local-file %source-dir
                      #:recursive? #t
                      #:select? (git-predicate %source-dir)))
  (arguments
    `(#:phases
      (modify-phases %standard-phases
        (add-before 'build 'remove-guix.scm
                    (lambda _ (delete-file "guix.scm"))))))
  (build-system guile-build-system)
  (native-inputs (list guile-3.0))
  (inputs (list guile-3.0-latest guile-libnotify))
  (synopsis "Remind you things periodically")
  (description "Reminder triggers desktop notifications periodically according
to a configuration file you provided.")
  (home-page "none")
  (license license:asl2.0))

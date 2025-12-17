(lang dune 3.6)

(generate_opam_files)

(package
 (name infexec)
 (synopsis "Infinitely execute a program")
 (maintainers brianwk)
 (depends lwt lwt_process reason ocaml dune ocaml-lsp-server ocamlformat))

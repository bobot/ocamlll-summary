========================
 Definition of a library
========================

This document summaries my, François Bobot, understanding of the discussion
around adding library management to the OCaml compiler and the simplification of
the OCaml ecosystem on libraries. Those discussions took place during the OCaml
Library Linking proposal project initiated by Daniel Bünzli and funded by the
OCaml foundation.

The management of libraries comprise two parts:
 - How a library is defined and located on the filesystem
 - How a library can be used

Those questions have already been tackled by `ocamlfind` developed by Gerd
Stolpmann since before 2004. So for each point the choices made by `ocamlfind`
are recalled.

 Definition of a library
------------------------

s

Directory location
******************

 Where the declaration of the libraries can be found is unavoidable for
library management:
  * pkg-config:

    By default, pkg-config looks in the directory prefix/lib/pkgconfig for these files; it will also look in the colon-separated (on Windows, semicolon-separated) list of directories specified by the PKG_CONFIG_PATH environment variable.

    ..
       LocalWords:  OCaml François Bobot Bünzli ocamlfind

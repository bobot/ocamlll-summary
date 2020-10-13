.. ocaml libraries summary documentation master file, created by
   sphinx-quickstart on Thu Oct  8 12:19:29 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

OCaml libraries discussion summary
===================================================

.. toctree::
   :maxdepth: 2

   location
   layout
   stdlib
   dynlink
   ppx
   compiler

This document summaries my, François Bobot, understanding of the discussion
around adding library management to the OCaml compiler and the simplification of
the OCaml ecosystem on libraries. Those discussions took place during the OCaml
Library Linking proposal project initiated by Daniel Bünzli and funded by the
OCaml foundation which lead to this refined `RFC`_. The :index:`RFC` makes some
choices that doesn't corresponds to a consensus.

.. _RFC : https://github.com/ocaml/RFCs/blob/e5f45ba6e9568c120c58c70de298c3a93704189a/rfcs/ocamlib.md

..
   The management of libraries comprise two parts:
    - How a library is defined and located on the file-system
    - How a library can be used

Those questions have already been tackled by :index:`ocamlfind` developed by Gerd
Stolpmann since before 2004. So for each point the choices made by ocamlfind
are recalled.

The propositions in each section are distinct and often incompatible. They show
point where the consensus have not been reached or which give interesting alternative.


..  LocalWords:  François Bobot OCaml Bünzli Gerd Stolpmann reimplementation

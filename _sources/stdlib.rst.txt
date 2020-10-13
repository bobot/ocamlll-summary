Library installed by the OCaml compiler
---------------------------------------

Currently :index:`ocamlfind` (and :index:`dune`) needs to create the configuration for the
libraries installed by the compiler (``unix``, ``threads``, ``str``, ...) for each of
its version:

 * for ocamlfind: https://github.com/ocaml/ocamlfind/blob/9e40620/configure#L505
 * for dune:
   https://github.com/ocaml/dune/blob/58cb185/src/dune_rules/findlib/meta.ml#L144

This adds an additional reason for which it is not possible to test the trunk
version of OCaml, for example when moving out a libraries (as append for ``num``).
And it adds possible errors and problems at unexpected time (deletion of
graphics from 4.09, https://github.com/ocaml/dune/pull/3855 )

However the installation directory has been a contentious subject in the past.

.. admonition:: Proposition

                To make the OCaml compiler libraries follow the layout for
                libraries is pushed at a later date.

However it is quite unsatisfying that the OCaml library can't be used
out-of-the-box so a backward compatible way can be tried.

.. admonition:: Proposition

                The installation directory is kept as it is, but a directory
                with the correct layout is added and is filled with hardlink to
                the other files. This directory is part of the built-in lookup
                path.

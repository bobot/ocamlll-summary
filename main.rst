.. ocaml libraries summary documentation master file, created by
   sphinx-quickstart on Thu Oct  8 12:19:29 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

OCaml libraries discussion summary
===================================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

This document summaries my, François Bobot, understanding of the discussion
around adding library management to the OCaml compiler and the simplification of
the OCaml ecosystem on libraries. Those discussions took place during the OCaml
Library Linking proposal project initiated by Daniel Bünzli and funded by the
OCaml foundation.

The management of libraries comprise two parts:
 - How a library is defined and located on the file-system
 - How a library can be used

Those questions have already been tackled by `ocamlfind` developed by Gerd
Stolpmann since before 2004. So for each point the choices made by `ocamlfind`
are recalled.

Definition of a library
***********************


Directory location
------------------

Where the declarations of the libraries can be found is unavoidable for
library management. Some examples:

  * pkg-config:

    By default, pkg-config looks in the directory `prefix/lib/pkgconfig` for these
    files; it will also look in the colon-separated (on Windows,
    semicolon-separated) list of directories specified by the `PKG_CONFIG_PATH`
    environment variable.

    -- pkg-config man page

  * tex:

    TEXINPUTS Search path for \input and \openin files. This should probably
    start with ''.'', so that user files are found before system files. An empty
    path component will be replaced with the paths defined in the texmf.cnf
    file. For example, set TEXINPUTS to ".:/home/usr/tex:" to prepend the
    current direcory and ''/home/user/tex'' to the standard search path.

    -- tex man page

  * ocamlfind:

    * The file findlib.conf contains the default `path`:

    The  directory  containing  findlib.conf is determined at build time (by running the configure script),
    the fallback default is /usr/local/etc. You can set a different location by  changing  the  environment
    variable OCAMLFIND_CONF which must contain the absolute path of findlib.conf.

    `path` The  search  path for META files/package directories. The variable  enumerates directories which
    are separated by colons (Windows:  semicolons), and these directories are tried in turn to  find
    a  certain    package.

    -- findlib.conf man page

    * `OCAMLPATH` allows to modifies it:

    OCAMLPATH This variable may contain an additional search path for package  directories. It is  treated  as
    if the directories were prepended to  the configuration variable path.

    -- findlib.conf man page


The different tools have similarities and differences:

A builtin list of paths:

  - without indirection: directly in the binary
  - with an indirection: the binaries contain the path to a configuration
        file which contains the list of paths to lookup.

.. note::
   The builtin lookup list of path must accept more than one elements because
   contrary to an `opam` installation, a distribution like Debian install
   package file in `/usr` and libraries compiled locally in `/usr/local`.
   So both place must be looked up.


An environment variable for modifying this list at runtime, which uses
colons (on windows, semicolon) as separators:

  - a final separator is just ignored
  - a final separator indicate to append the default path

Other choices break the simple method of appending to the variable:

| FOO=new_dir:$FOO

The second choice allows the user to completely override default values for the
lookup path.

| FOO=only_dir

.. admonition:: Proposition1

  Reusing the variable `OCAMLPATH` seems the most natural things to do, in that
  case keeping the semantic of ocamlfind is mandatory: final separator ignored,
  builtin path appended.

  A new variable `BUILTIN_OCAMLPATH` in the `Makefile.config` installed in
  the standard library path contains the builtin list of path

We could also add the variable to `ocamlc -config` but it complicates the
modification after installation. A new file `ocaml.config` can be chosen instead
of `Makefile.config` .

.. admonition:: Proposition2

                add updated proposition from RFC

Library layout
--------------

How a library name is resolved and what are the constraints on the libraries
define a trade-off between the possibilities proposed to the library developers
and the simplicity to support it for the tool developers.

Examples:

  * python [python_module]_ in the lookup-path considers directories containing
    the file `__init__` as packages, and such sub-directories as sub-package
    accessible through `package.sub_package`, all the python file are directly
    in the directories

.. [python_module]  https://docs.python.org/3.5/tutorial/modules.html#packages

  * pkg-config only lookup `.pc` files in the lookup directories which are
    configuration file for the library:

     - name
     - directories
     - version
     - dependencies
     - other custom variables

  * ocamlfind as a dual approach, it allows a package `p` to be defined by
    `p/META` and `META.p` in one of the lookup directories. The `META`
    configuration file is quite complexe and powerful:

     - it allows to select the value of a variable according to some predicate
       (e.g is it compiling in byte or native, is the thread library used);
     - it allows one library to be composed of more than one archive
     - it allows to define a library only if some file is present

    However it is also restricting because one `META` file need to define all
    the sub-libraries of the package. So it is not possible to install a
    sub-library at a latter time (except by rewriting the file, which is usually
    not well accepted by package managers).

There is a consensus for simplifying the layout of the library:

  * only 




Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

..  LocalWords:  François Bobot OCaml Bünzli Gerd Stolpmann

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

The propositions in each section are distinct and often incompatible. They show
point where the consensus have not been reached or which give interesting alternative.

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

.. admonition:: Proposition

  Reusing the variable `OCAMLPATH` seems the most natural things to do, in that
  case keeping the semantic of ocamlfind is mandatory: final separator ignored,
  builtin path appended.

  A new variable `BUILTIN_OCAMLPATH` in the `Makefile.config` installed in
  the standard library path contains the builtin list of path

We could also add the variable to `ocamlc -config` but it complicates the
modification after installation. A new file `ocaml.config` can be chosen instead
of `Makefile.config` .

.. admonition:: Proposition

                add updated proposition from RFC

..todo:: add updated proposition from RFC

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
    configuration file for the library which contains:

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

  * one directory is a library
  * There is only one archive for each compilation mode named `lib.cma`,
    `lib.cmxa`, `lib.cmxs` (it is always `lib` even for `foo` library).
  * All the needed `cmi`, `cmx`, `cmt`, `.a`, `cmo` are in this directory
  * The sub-directories are sub-libraries (`foo/bar` corresponds to `foo.bar`).

..todo: add restrictions of names from the RFC

.. admonition:: Proposition

                The information about library dependencies is stored in the
                archives. The information must be the same for the three
                archives. It is stored by the compiler and specified to it using
                a new option `-require` during archive creation.

                External tools would obtain this information from `ocamlobjinfo`.


This proposition has the advantage of not requiring new files and of putting
together all the information that the static or dynamic linking phase needs in
one place since the archive are already read. But it has some disadvantage:
- to duplicate the information, which can create subtitle bugs
- be a binary format, so `rgrep` can't be used for debugging
- it is not extensible, in this proposition `ppx` support would need an
  additional file.

.. admonition:: Proposition

                A mandatory configuration file `lib.META` which use the same format than
                `ocamlc -config` (`key:value`) with possibly the following
                optional keys:

                - `requires`: string, with a space separated list of libraries
                  (default empty)
                - `version`: string, a version with debian semantic for the
                  comparison [debian_version]_
                - `synopsis`: string, a oneliner to use when listing libraries
                - `private` : boolean, indicates if the library should be listed

                As for python `__init__.py` a directory that doesn't contains
                `lib.META` is not considered as a library or sub-library.

                Custom key can be used but they must use a dot inside
                `qualifier.key`. Other keys without dot are restricted to future
                extensions.

.. [debian_version] https://www.debian.org/doc/debian-policy/ch-controlfields.html#version

Library installed by the OCaml compiler
---------------------------------------

Currently ocamlfind (and dune) needs to create the configuration for the
libraries installed by the compiler (`unix`, `threads`, `str`, ...) for each of
its version.
 - for ocamlfind: https://github.com/ocaml/ocamlfind/blob/9e40620/configure#L505
 - for dune:
   https://github.com/ocaml/dune/blob/58cb185/src/dune_rules/findlib/meta.ml#L144

This adds an additional reason for which it is not possible to test the trunk
version of OCaml, for example when moving out a libraries (as append for `num`).

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


Dynamic Linking
---------------

Dynamic linking as been well supported by OCamlfind since 2015:
  - specify the `plugin` variable to specify the shared archive in `META` file
  - when `ocamlfind` link an executable which depends on `findlib.dynload`, it registers the statically linked
    library by linking newly created module.
  - The library `findlib.dynload` allows at runtime to load a library
    and its dependencies (hide the dynlink details)

Since 2018, Dune also does this trick at link time if `findlib.dynload` is a
dependency.

Currently the development of another `findlib.dynload` is not possible in a
compatible way because the set of package already loaded is not shared. Moreover
the linking trick could perhaps be simplified.

.. admonition:: Proposition

                Define a little project which would only keep the set of name of
                linked libraries. It is empty at the start, an external module
                should add the statically linked modules.

               | val all_libraries : unit -> string list
               | (** [all_libraries ()] is the set of loaded libraries statically
               | or dynamically. *)
               |
               | val has_library : string -> bool
               | (** [has_library l] is [List.mem l (all_libraries ())]. *)
               |
               | val add_library: string -> unit
               | (** [add_library l] consider this library as loaded *)


It is even possible to define this library without an implementation, the tool
that run the ocaml linker (e.g ocamlfind, dune, ocamlbuild, brzo) could create a
specific implementation which would directly initialize this database with the
statically loaded library of the executable.

However the `dynlink` module is a nice place to add that.

.. admonition:: Proposition

                Adds the function of the previous proposition to the `dynlink`
                module.

The linker can even simplify the initialization of the data-structure.

.. admonition:: Proposition

                ocamlc and ocamlopt gain an optional `--assume-require name` in
                link mode, which adds this `name` to the set of loaded
                libraries. It doesn't change in any way what is linked, only
                change the database.

The name `--assume-require` follows the one with similar use of the RFC for
simplicity. But another name could be more appropriate.


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

.. todolist::

..  LocalWords:  François Bobot OCaml Bünzli Gerd Stolpmann reimplementation

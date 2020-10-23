Library layout
--------------

How a library name is resolved and what are the constraints on the libraries
define a trade-off between the possibilities proposed to the library developers
and the simplicity to support it for the tool developers.

Examples:

  * :index:`python` considers directories in the lookup-path containing
    the file ``__init__`` as packages, and such sub-directories as sub-package
    accessible through ``package.sub_package``, all the python file are directly
    in the directories. https://docs.python.org/3.5/tutorial/modules.html#packages

  * :index:`pkg-config` only lookup ``.pc`` files in the lookup directories which are
    configuration file for the library which contains:

     - name
     - directories
     - version
     - dependencies
     - other custom variables

  * :index:`ocamlfind` as a dual approach, it allows a package ``p`` to be defined by
    ``p/META`` and ``META.p`` in one of the lookup directories. The ``META``
    configuration file is quite complexe and powerful:

     - it allows to select the value of a variable according to some predicate
       (e.g is it compiling in byte or native, is the thread library used);
     - it allows one library to be composed of more than one :index:`archive`
     - it allows to define a library only if some file is present

    However it is also restricting because one ``META`` file need to define all
    the sub-libraries of the package. So it is not possible to install a
    sub-library at a latter time (except by rewriting the file, which is usually
    not well accepted by package managers).

There is a consensus for simplifying the layout of the library:

  * one directory is one library
  * There is only one :index:`archive` for each compilation mode named ``lib.cma``,
    ``lib.cmxa``, ``lib.cmxs`` (it is always ``lib`` even for ``foo`` library).
  * All the needed ``.cmi``, ``.cmx``, ``.cmt``, ``.a``, ``.cmo`` are in this directory.
  * The sub-directories are sub-libraries (``foo/bar`` corresponds to
    ``foo.bar``).
  * The RFC lists some restrictions in the naming of libraries.

.. note::

   The fact that sub-directories are sub-libraries (``foo/bar`` corresponds to
   ``foo.bar``) is problematic for avoiding file conflict as presented at the
   end of this section. So ``foo.bar/`` could be considered. This choice is
   completely orthogonal to all the propositions.


.. admonition:: Proposition

                The information about library dependencies is stored in the
                archives. The information must be the same for the three
                archives. It is stored by the compiler and specified to it using
                a new option ``-require`` during archive creation.

                External tools would obtain this information from ``ocamlobjinfo``.


This proposition has the advantage of not requiring new files and of putting
together all the information that the static or dynamic linking phase needs in
one place since the archive are already read. But it has some disadvantage:

 * to duplicate the information, which can create subtitle bugs
 * be a binary format, so ``rgrep`` can't be used for debugging
 * it is not extensible, in this proposition ``ppx`` support would need an
   additional file.

.. admonition:: Proposition

                A mandatory configuration file ``lib.META`` which use the same format than
                ``ocamlc -config`` (``key:value``) with possibly the following
                optional keys with the values of the given type:

                - ``requires``: string, with a space separated list of libraries
                  (default empty)
                - ``version``: string, a version with `debian semantic`_ for the
                  comparison
                - ``synopsis``: string, a oneliner to use when listing libraries
                - ``private`` : boolean, indicates if the library should be listed

                As for python ``__init__.py``, a directory that doesn't contains
                ``lib.META`` is not considered as a library or sub-library.

                Custom key can be used but they must use a dot inside
                ``qualifier.key``. Other keys without dot are restricted to future
                extensions.

.. _debian semantic: https://www.debian.org/doc/debian-policy/ch-controlfields.html#version

In both proposition there is no definition of what is a package. It is a
consensus that removing this notion would be an improvement of the ecosystem.

The notion of package appeared and remains for at least two reasons:
- the restriction of the META files which force to install all
the libraries of a package at the same time.
- the fact that in Opam, the section (``libdir``, ``share``) of an `X.install`
  file of a package ``X`` corresponds to ``<share>/X``, ``<libdir>/X``.
  https://opam.ocaml.org/doc/Manual.html#lt-pkgname-gt-install . Dune used the
  notion of package for this reason.

However since with these proposals the restriction in the META file is lifted and
since in Opam 2.0.0 the section ``libdir_root`` and ``share_root`` have been
added, it will be possible to install each library `X.Y` in the right directory,
``<libdir>/X/Y`` and ``<share>/X/Y``. It doesn't mean that
the current opam packages must be splitted, just that it is a possibility let to
the packager.

.. note::

   In Debian the directory for the ocaml library file and the other library
   (binary) file is separated, it is not the case in Opam. So in opam even if
   the ocaml library layout avoid collision between two library when one is the
   prefix of another, we could have collision with the other library file.
   Moreover if we choose to put the file for ``X`` and ``X.Y`` in ``<share>/X``
   and ``<share>/X/Y``, we coud have even more collisions.

   So putting the file of ``X.Y`` in ``<share>/X.Y/`` and ``<libdir>/X.Y`` would
   avoid those possible collisions. However that is not compatible with the
   namespace proposal.

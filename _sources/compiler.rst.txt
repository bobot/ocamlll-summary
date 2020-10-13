Lookup in the compiler
----------------------

.. _RFC : https://github.com/ocaml/RFCs/blob/e5f45ba6e9568c120c58c70de298c3a93704189a/rfcs/ocamlib.md

The previous chapters discussed how the libraries are found and described.
Although some modifications of the compiler distribution have already been
discussed:

  * the possibility to install the libraries installed by the compiler in a way
    that respect the specifications
  * the possibility to have the set of loaded libraries stored in the dynlink module.

The compiler in itself do not need to know yet what are libraries and how to look
them up. This section discussed the additions, mainly options or commands, to the compiler commands ``ocamlc``,
``ocamlopt`` and the toplevel.

Since some of the new ecosystem part are not yet well defined (libraries that come
from the compiler and ppx), it seems natural to postpone this part which adds
new option that will have to be maintained in the futur. In the meantime
:index:`ocamlfind` will offer all the features during the migration to
the new layout for the developpers.

.. admonition:: Proposition

                Don't add yet new options for the developpers to the compiler
                commands.

.. index:: RFC

.. admonition:: Proposition

                Add the options from the `RFC`_ (which choose to add the
                dependencies in the archive) :

                * compilation phase: ``-require`` for using a library
                * archive creation phase: ``-require`` for registrering a
                  dependency
                * linking phase: ``-require`` for linking and registring a static library
                * linking phase: ``-assume-require`` for registring without
                  linking a library
                * Add the ``-L`` option in order to extend the ``OCAMLPATH``

                Add the command:
                 - ``#require`` in the toplevel

                Add the ``Dynlink.require`` function for loading a library


However we discussed a lot those options:

 * Particularly we modified the original proposition in order to recover
   backward compatibility: archive added for linking directly on the command line
   ``a.cma`` or ``a.cmxa`` don't anymore automatically add their dependencies.
   Before That was breaking compatibility since developpers currently list all
   the dependencies and we can't link multiple time the same archive, so an
   option was needed for recovering the old behavior.

 * If the information about required libraries is in the :index:`archive` files
   the archive creation phase need a ``-require`` option that it not needed when
   the information is in ``lib.META`` file.

 * The linking phase of the `RFC`_ currently accept directly archives file
   ``lib.cmxa``:

    * It allows to directly get the requirements of a local archive
    * But it is very hard to use if one use more than one local library, it is
      easier to use the ``-L`` and the name of the local libraries.
    * But it could be simplified by accepting a directory instead of an archive,
      which has the advantage to give the name of the added library ``-require local/foo/``

 * Storing the dependencies in the shared archive ``.cmxs`` allows to have a
   plugin system where ``Dynlink.require`` can be used to directly load the
   file. Otherwise a plugins need to be a directory with a ``lib.META`` and
   ``lib.cmxs`` file, and ``Dynlink.require`` would load the directory.

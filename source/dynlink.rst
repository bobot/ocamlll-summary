Dynamic Linking
---------------

Dynamic linking as been well supported by :index:`ocamlfind` since 2015:
  - specify the ``plugin`` variable to specify the shared :index:`archive` in ``META`` file
  - when ``ocamlfind`` link an executable which depends on ``findlib.dynload``, it registers the statically linked
    library by linking newly created module.
  - The library ``findlib.dynload`` allows at runtime to load a library
    and its dependencies (hide the dynlink details)

Since 2018, Dune also does this trick at link time if ``findlib.dynload`` is a
dependency.

Currently the development of another ``findlib.dynload`` is not possible in a
compatible way because the set of package already loaded is not shared. Moreover
the linking trick could perhaps be simplified.

.. admonition:: Proposition

                Define a little project which would only keep the set of name of
                linked libraries. It is empty at the start, an external module
                should add the statically linked modules.

               .. code-block:: ocaml

                  val all_libraries : unit -> string list
                  (** [all_libraries ()] is the set of loaded libraries statically
                      or dynamically. *)

                  val has_library : string -> bool
                  (** [has_library l] is [List.mem l (all_libraries ())]. *)

                  val add_library: string -> unit
                  (** [add_library l] consider this library as loaded *)


It is even possible to define this library without an implementation, the tool
that run the ocaml linker (e.g :index:`ocamlfind`, :index:`dune`,
:index:`ocamlbuild`, :index:`brzo`) could create a specific implementation which
would directly initialize this database with the statically loaded library of
the executable.

However the ``dynlink`` module is a nice place to add that.

.. admonition:: Proposition

                Adds the function of the previous proposition to the ``dynlink``
                module.

The linker can even simplify the initialization of the data-structure.

.. admonition:: Proposition

                ocamlc and ocamlopt gain an optional ``--assume-require name`` in
                link mode, which adds this ``name`` to the set of loaded
                libraries. It doesn't change in any way what is linked, only
                change the database.

The name ``--assume-require`` follows the one with similar use of the `RFC`_ for
simplicity. But another name could be more appropriate.

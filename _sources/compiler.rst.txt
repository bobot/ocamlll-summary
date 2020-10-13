Lookup in the compiler
----------------------

The previous chapters discussed how the libraries are found and described.
Although some modifications of the compiler distribution have already been
discussed:

  * the possibility to install the libraries installed by the compiler in a way
    that respect the specifications
  * the possibility to have the set of loaded libraries stored in the dynlink module.

The compiler in itself do not need to know yet what are libraries and how to look
them up. This section discussed the additions, mainly options or commands, to the compiler commands ``ocamlc``,
``ocamlopt`` and the toplevel.

Since some of the new ecosystem part are not yet well defined, it seems natural
to postpone this part which adds new option that will have to be maintained in
the futur. In the meantime :index:`ocamlfind`

PPX specification
-----------------

PPX are an important part of the OCaml ecosystem. At first they were only
commands specified using the ``-ppx`` option of the compiler. However requirements
for better error message and efficiency turned them into libraries:

  * which can interact more precisely with a generic ppx framework (e.g.
    ``deriving``)
  * which can be linked together in order to have only one binary to run, saving
    fork time and marshalling time.

Moreover a PPX could require a runtime library that will be called by the
generated code. It is useful for the PPX library to points to its runtime
library so that the dependency can be automatically added.

:index:`Ocamlfind <single: ocamlfind>` features such support and accept ppx to be specified as ``-package``.
The fact to use the same option for libraries and ppxs can be seen as mixing to
different concept, or it could be seen as a simplication. Indeed for the
developpers it is just a way to require the use of some features (an API, a deriving,
a way to write some code) in theirs project.

During the discussion about library management, we only discussed a little the
ppx part. In all the propositions the information needed for ppx was added
through a file. When adding the library requirements in :index:`archives<single:archive>` an additional
file was needed. In the case of ``lib.META``, the informations can be specified
there since the format is extensible.

.. admonition:: Proposition

                The information for ppx libraries will be present in a file in
                the directory. In ``lib.META`` if it is used for storing
                dependencies, a unspecified file when the dependencies are in
                the archives.

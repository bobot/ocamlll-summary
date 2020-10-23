PPX specification
-----------------

PPX are an important part of the OCaml ecosystem. At first they were only
commands specified using the ``-ppx`` option of the compiler. However
requirements for better error message, efficiency and a composition semantic
that allows developer to understand and reason about how their ppx rewriter will
interact with other arbitrary ppx rewriter, turned them into libraries:

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
ppx part. In the case of ``lib.META``, the informations can be specified
there since the format is extensible.

.. admonition:: Proposition

                The information for ppx libraries will be present in
                ``lib.META``.

 When adding the library requirements in :index:`archives<single:archive>` an additional
file was needed. But if the only needed information for a ppx is the runtime
dependency, only the presence of the file is needed.

.. admonition:: Proposition

                A ppx library is detected by the presence of a `ppx.exe` file,
                which could be executable and apply the ppx, or just be an empty
                non executable file (e.g plugin for deriving). The runtime
                dependency will be found using a convention, e.g `PPX.runtime`.

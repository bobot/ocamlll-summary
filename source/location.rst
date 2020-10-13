Directory location
------------------

Where the declarations of the libraries can be found is unavoidable for
library management. Some examples:

  * :index:`pkg-config`:

    By default, pkg-config looks in the directory ``prefix/lib/pkgconfig`` for these
    files; it will also look in the colon-separated (on Windows,
    semicolon-separated) list of directories specified by the ``PKG_CONFIG_PATH``
    environment variable.

    -- pkg-config man page

  * :index:`tex`:

    TEXINPUTS Search path for \input and \openin files. This should probably
    start with ''.'', so that user files are found before system files. An empty
    path component will be replaced with the paths defined in the texmf.cnf
    file. For example, set TEXINPUTS to ".:/home/usr/tex:" to prepend the
    current direcory and ''/home/user/tex'' to the standard search path.

    -- tex man page

  * :index:`ocamlfind`:

    * The file findlib.conf contains the default ``path``:

    The  directory  containing  findlib.conf is determined at build time (by running the configure script),
    the fallback default is /usr/local/etc. You can set a different location by  changing  the  environment
    variable OCAMLFIND_CONF which must contain the absolute path of findlib.conf.

    ``path`` The  search  path for META files/package directories. The variable  enumerates directories which
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
   contrary to an ``opam`` installation, a distribution like Debian install
   package file in ``/usr`` and libraries compiled locally in ``/usr/local``.
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

  Reusing the variable ``OCAMLPATH`` seems the most natural things to do, in that
  case keeping the semantic of ocamlfind is mandatory: final separator ignored,
  builtin path appended.

  A new variable ``BUILTIN_OCAMLPATH`` in the ``Makefile.config`` installed in
  the standard library path contains the builtin list of path, obtained from the configure.

We could also add the variable to ``ocamlc -config`` but it complicates the
modification after installation. A new file ``ocaml.config`` can be chosen instead
of ``Makefile.config`` .

Another proposition is to be more explicit, and allows to remove the builtin path

.. admonition:: Proposition

   The value of the ``OCAMLPATH`` environment variable is the only path lookup
   if set. If unset a builtin path is used. So appending to the environement is
   done by:

   .. code-block:: sh

      OCAMLPATH=~/.local/lib/ocaml:$(ocamlc -ocamlpath)

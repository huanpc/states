..
   Author: Dang Tung Lam <lam@robotinfra.com>
   Maintainer: Diep Pham <favadi@robotinfra.com>

Ejabberd
========

Introduction
------------

:doc:`/ejabberd/doc/index` is a `Jabber/XMPP
<http://en.wikipedia.org/wiki/XMPP>`_ instant messaging server, licensed under
GPLv2 (Free and Open Source), written in :doc:`/erlang/doc/index`. Among other
features, ejabberd is cross-platform, fault-tolerant, clusterable and modular.

.. Copied from https://www.ejabberd.im on 2015-01-13

Security Issue
--------------

There is no way to disable SSLv3 in version 2.1.10 without
re-compiling the source code. This is a dirty hack, so leave it like
that until there is a build for Ubuntu that fix it.

Links
-----

* `Ejabberd page <https://www.ejabberd.im>`_
* `Wikipedia <http://en.wikipedia.org/wiki/Ejabberd>`_

Related Formulas
----------------

* :doc:`/apt/doc/index`
* :doc:`/erlang/doc/index`
* :doc:`/nginx/doc/index`
* :doc:`/postgresql/doc/index`
* :doc:`/ssl/doc/index`

Content
-------

.. toctree::
    :glob:

    *

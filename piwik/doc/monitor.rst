Monitor
=======

.. |deployment| replace:: piwik

.. warning::

   In this document, when refer to a pillar key ``pillar_prefix``
   means ``piwik``.

Mandatory
---------

.. include:: /uwsgi/doc/monitor.inc

.. include:: /mysql/doc/monitor.inc

.. include:: /nginx/doc/monitor.inc

.. include:: /backup/doc/monitor.inc

.. include:: /backup/doc/monitor_procs.inc

.. include:: /backup/doc/monitor_mysql_procs.inc

.. include:: /backup/doc/monitor_mysql_age.inc

Optional
--------

Only use if :ref:`pillar-piwik-ssl` is turned on.

.. include:: /nginx/doc/monitor_ssl.inc

Only use if an :ref:`glossary-IPv6` address is present.

.. include:: /nginx/doc/monitor_ipv6.inc

{#-
-*- ci-automatic-discovery: off -*-

Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Bruno Clermont <bruno@robotinfra.com>
Maintainer: Viet Hung Nguyen <hvn@robotinfra.com>
-#}
include:
  - postgresql.common.nrpe
  - postgresql.server.nrpe
  - postgresql.standby

extend:
  postgresql_monitoring:
    postgres_user:
      - require:
        - service: postgresql

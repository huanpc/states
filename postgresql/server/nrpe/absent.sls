{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Quan Tong Anh <quanta@robotinfra.com>
Maintainer: Quan Tong Anh <quanta@robotinfra.com>
-#}
/etc/cron.d/passive-checks-postgresql.server:
  file:
    - absent

/usr/lib/nagios/plugins/check_pgsql_query.py:
  file:
    - absent

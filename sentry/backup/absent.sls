{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Bruno Clermont <bruno@robotinfra.com>
Maintainer: Van Pham Diep <favadi@robotinfra.com>

Undo sentry.backup state.
-#}
backup-sentry:
  file:
    - absent
    - name: /etc/cron.daily/backup-sentry

{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Nicolas Plessis <niplessis@gmail.com>
Maintainer: Viet Hung Nguyen <hvn@robotinfra.com>
-#}
include:
  - backup.absent
  - backup.client.absent

s3lite:
  file:
    - absent
    - name: /usr/local/s3lite

/etc/s3lite.yml:
  file:
    - absent

/usr/local/bin/s3lite:
  file:
    - absent

{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Quan Tong Anh <quanta@robotinfra.com>
Maintainer: Quan Tong Anh <quanta@robotinfra.com>
-#}
include:
  - doc
  - pysc
  - pysc.nrpe

test:
  module:
    - run
    - name: pip.list
    - prefix: pysc
    - require:
      - module: pysc
  monitoring:
    - run_all_checks
    - order: last

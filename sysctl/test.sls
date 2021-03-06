{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

include:
  - doc
  - sysctl

test:
  qa:
    - test_pillar
    - name: sysctl
    - doc: {{ opts['cachedir'] }}/doc/output
    - require:
      - cmd: doc

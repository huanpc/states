{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

include:
  - doc
  - xinetd
  - xinetd.diamond
  - xinetd.nrpe

{%- from 'cron/test.jinja2' import test_cron with context %}
{%- from 'diamond/macro.jinja2' import diamond_process_test with context %}

{%- call test_cron() %}
- sls: xinetd
- sls: xinetd.diamond
- sls: xinetd.nrpe
{%- endcall %}

test:
  monitoring:
    - run_all_checks
    - wait: 60
    - order: last
    - require:
      - cmd: test_crons
  diamond:
    - test
    - map:
        ProcessResources:
    {{ diamond_process_test('xinetd') }}
    - require:
      - monitoring: test
      - sls: xinetd
      - sls: xinetd.diamond
  qa:
    - test
    - name: xinetd
    - pillar_doc: {{ opts['cachedir'] }}/doc/output
    - require:
      - monitoring: test
      - cmd: doc

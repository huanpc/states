{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Bruno Clermont <bruno@robotinfra.com>
Maintainer: Viet Hung Nguyen <hvn@robotinfra.com>
-#}
{%- from 'cron/test.jinja2' import test_cron with context %}
{%- from 'diamond/macro.jinja2' import diamond_process_test with context %}
include:
  - doc
  - jenkins
  - jenkins.backup
  - jenkins.backup.diamond
  - jenkins.backup.nrpe
  - jenkins.diamond
  - jenkins.nrpe

{%- call test_cron() %}
- sls: jenkins
- sls: jenkins.backup
- sls: jenkins.backup.nrpe
- sls: jenkins.diamond
- sls: jenkins.nrpe
- cmd: wait_for_jenkins_to_start_and_create_file_before_running_crons
{%- endcall %}

wait_for_jenkins_to_start_and_create_file_before_running_crons:
  cmd:
    - run
    - name: sleep 30

test:
  diamond:
    - test
    - map:
        ProcessResources:
    {{ diamond_process_test('jenkins') }}
    - require:
      - sls: jenkins
      - sls: jenkins.diamond
  monitoring:
    - run_all_checks
    - order: last
    - require:
      - cmd: test_crons
  qa:
    - test
    - name: jenkins
    - additional:
      - jenkins.backup
    - pillar_doc: {{ opts['cachedir'] }}/doc/output
    - require:
      - monitoring: test
      - cmd: doc

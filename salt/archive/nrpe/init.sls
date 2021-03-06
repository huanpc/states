{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- from 'nrpe/passive.jinja2' import passive_check with context %}
{%- set source = salt['pillar.get']('salt_archive:source', False) %}
include:
  - apt.nrpe
  - bash.nrpe
  - cron.nrpe
  - nginx.nrpe
  - nrpe
  - pysc.nrpe
  - rsync.nrpe
  - rsyslog.nrpe
  - ssh.server.nrpe
{% if salt['pillar.get']('salt_archive:ssl', False) %}
  - ssl.nrpe
{%- endif %}
  - sudo
  - sudo.nrpe
{%- if not source %}
  - requests.nrpe
{%- endif %}

sudo_salt.archive_nrpe:
  file:
    - managed
    - name: /etc/sudoers.d/salt_archive_nrpe
    - template: jinja
    - source: salt://salt/archive/nrpe/sudo.jinja2
    - mode: 440
    - user: root
    - group: root
    - require:
      - pkg: sudo
    - require_in:
      - service: nagios-nrpe-server

/etc/sudoers.d/salt_archive_server_nrpe:
  file:
    - absent

{{ passive_check('salt.archive', pillar_prefix='salt_archive', check_ssl_score=True) }}

include:
  - apt

rsyslog:
  pkg:
    - installed
    - require:
      - cmd: apt_sources
      - pkg: remove_klogd_if_exist
      - pkg: gsyslogd
  file:
    - managed
    - name: /etc/rsyslog.conf
    - template: jinja
    - source: salt://rsyslog/config.jinja2
  service:
    - running
    - order: 50
    - watch:
      - pkg: rsyslog
      - file: rsyslog
      - cmd: clear_rsyslog_default_config

remove_klogd_if_exist:
  pkg:
    - purged
    - name: klogd
    - require:
      - service: gsyslogd

gsyslogd:
  service:
    - dead
  file:
    - absent
    - name: /etc/init/gsyslogd.conf
    - require:
      - service: gsyslogd
  pkg:
    - purged
    - name: syslogd
    - require:
      - service: gsyslogd

{%- for filename in ('/usr/local/gsyslog', '/etc/gsyslog.d', '/etc/gsyslogd.conf') %}
{{ filename }}:
  file:
    - absent
    - require:
      - file: gsyslogd
{%- endfor %}

clear_rsyslog_default_config:
  cmd:
    - run
    - name: rm -f /etc/rsyslog.d/*
    - onlyif: test -e /etc/rsyslog.d/50-default.conf
    - require:
      - pkg: rsyslog

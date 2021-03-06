{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- set files_archive = salt['pillar.get']('files_archive', False) %}
{%- set version = "2.14.3-1" %}
{%- set repo = files_archive|replace('https://', 'http://') ~ "/mirror/piwik/" ~ version
  if files_archive else "http://archive.robotinfra.com/mirror/piwik/2.14.3-1/"
%}
{%- set hostnames = salt['pillar.get']('piwik:hostnames') %}
{%- set ssl = salt['pillar.get']('piwik:ssl', False) %}
{%- set admin_username = salt['pillar.get']('piwik:admin:username') %}
{%- set admin_password = salt['pillar.get']('piwik:admin:password') %}
{%- set admin_email = salt['pillar.get']('piwik:admin:email') %}
{%- set db_password = salt["pillar.get"]("piwik:db:password") %}
{%- set is_test = salt['pillar.get']('__test__', False) %}

include:
  - apt
  - bash
  - cron
  - hostname
  - mysql.server
  - nginx
  - php
  - php.geoip
  - pip
  - python
  - sudo
  - uwsgi.php
  - virtualenv
{%- if ssl %}
  - ssl
{%- endif %}

piwik:
  pkgrepo:
    - managed
    - name: deb {{ repo }} piwik main
    - key_url: salt://piwik/key.gpg
    - file: /etc/apt/sources.list.d/piwik.list
    - clean_file: True
    - require:
      - pkg: apt_sources
  pkg:
    - latest
    - name: piwik
    - require:
      - service: mysql-server
      - pkg: php
      - pkgrepo: piwik
  mysql_database:
    - present
    - name: piwik
    - require:
      - service: mysql-server
      - pkg: python-mysqldb
  mysql_user:
    - present
    - host: 127.0.0.1
    - name: piwik
    - password: {{ db_password }}
    - require:
      - service: mysql-server
      - pkg: python-mysqldb
  mysql_grants:
    - present
    - grant: all privileges
    - user: piwik
    - database: piwik.*
    - host: 127.0.0.1
    - require:
      - mysql_user: piwik
      - mysql_database: piwik

/var/lib/piwik/geoip:
  file:
    - directory
    - user: www-data
    - group: www-data
    - mode: 755
    - require:
      - user: web
      - pkg: piwik

piwik_geoip:
  pkg:
    - latest
    - pkgs:
      - gzip
      - wget
    - require:
      - cmd: apt_sources
  file:
    - managed
    - name: /etc/cron.daily/piwik-geoip
    - source: salt://piwik/cron_daily.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 500
    - require:
      - file: bash
      - file: /var/lib/piwik/geoip
      - pkg: cron
      - user: web
{%- if not is_test %}
  cmd:
    - run
    - name: /etc/cron.daily/piwik-geoip
    - unless: test -f /var/lib/piwik/geoip/GeoIPCity.dat
    - require:
      - file: piwik_geoip
    - require_in:
      - module: piwik_uwsgi
{%- endif %}

piwik_uwsgi:
  file:
    - managed
    - name: /etc/uwsgi/piwik.yml
    - template: jinja
    - user: root
    - group: www-data
    - mode: 440
    - source: salt://uwsgi/template.jinja2
    - template: jinja
    - context:
        dir: /usr/share/piwik
        chdir: /usr/share/piwik
        appname: piwik
        php_settings: '  php-set: geoip.custom_directory=/var/lib/piwik/geoip'
    - require:
      - mysql_grants: piwik
      - service: uwsgi
      - service: mysql-server
  module:
    - wait
    - name: file.touch
    - m_name: /etc/uwsgi/piwik.yml
    - require:
      - file: /etc/uwsgi/piwik.yml
    - watch:
      - file: piwik_uwsgi
      - pkg: piwik
      - pkg: php_geoip

/etc/nginx/conf.d/piwik.conf:
  file:
    - managed
    - template: jinja
    - source: salt://piwik/nginx.jinja2
    - user: root
    - group: www-data
    - mode: 440
    - context:
        appname: piwik
        root: /usr/share/piwik
    - require:
      - pkg: nginx
      - pkg: piwik
    - watch_in:
      - service: nginx

piwik_initial_setup:
  virtualenv:
    - managed
    - name: /usr/local/piwik
  file:
    - managed
    - name: {{ opts['cachedir'] }}/pip/piwik
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://piwik/requirements.jinja2
    - require:
      - virtualenv: piwik_initial_setup
  pip:
    - installed
    - requirements: {{ opts['cachedir'] }}/pip/piwik
    - upgrade: True
    - bin_env: /usr/local/piwik
    - require:
      - virtualenv: piwik_initial_setup
    - watch:
      - file: piwik_initial_setup
      - module: pip
  cmd:
    - wait_script
    - source: salt://piwik/initial_setup.py
    - name: >
        initial_setup.py
        --host '{{ hostnames[0] }}'
        --url 'http{% if ssl %}s{% endif %}://127.0.0.1'
        --user '{{ admin_username }}' --password '{{ admin_password }}'
        --email '{{ admin_email }}' --database-password '{{ db_password }}'
        --test
    - require:
      - pip: piwik_initial_setup
      - file: python
      - host: hostname
    - watch:
        - mysql_database: piwik

piwik_archive:
  file:
    - managed
    - name: /etc/cron.hourly/piwik-archive
    - source: salt://piwik/cron_hourly.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 500
    - require:
      - file: bash
      - pkg: cron
      - pkg: piwik
      - pkg: sudo
      - user: web

{%- if ssl %}
extend:
  nginx:
    service:
      - watch:
        - cmd: ssl_cert_and_key_for_{{ ssl }}
{%- endif %}

include:
  - apt

mariadb:
  pkgrepo:
    - managed
    - keyid: '0xcbcb082a1bb943db'
    - keyserver: keyserver.ubuntu.com
{%- if 'files_archive' in pillar %}
    - name: deb {{ pillar['files_archive'] }}/mirror/mariadb/5.5.31 {{ grains['lsb_codename'] }} main
{%- else %}
    - name: deb http://repo.maxindo.net.id/mariadb/repo/5.5/ubuntu precise main
{%- endif %}
    - file: /etc/apt/sources.list.d/mariadb.list
    - require:
      - pkg: python-apt
      - pkg: python-software-properties
  pkg:
    - installed
    - name: libmysqlclient18
    - version: 5.5.31+maria-1~precise
    - require:
      - pkgrepo: mariadb
      - pkg: mysql-common
{#- prevent dist_upgrade #}
  cmd:
    - run
    - name: echo libmysqlclient18 hold | dpkg --set-selections
    - unless: dpkg --get-selections | grep libmysqlclient18 | grep -q hold
    - require:
      - pkg: mariadb

{#- specify version to prevent conflict with mysql #}
mysql-common:
  pkg:
    - installed
    - version: 5.5.31+maria-1~precise
    - require:
      - pkgrepo: mariadb

hold_mysql_common:
  cmd:
    - run
    - name: echo mysql-common hold | dpkg --set-selections
    - unless: dpkg --get-selections | grep mysql-common | grep -q hold
    - require:
      - pkg: mariadb
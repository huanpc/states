{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Bruno Clermont <bruno@robotinfra.com>
Maintainer: Viet Hung Nguyen <hvn@robotinfra.com>
-#}
include:
  - packages

apt.conf:
  file:
    - managed
    {#- 99 prefix is to make sure the config file is the last one to be
        applied #}
    - name: /etc/apt/apt.conf.d/99local
    - source: salt://apt/config.jinja2
    - user: root
    - group: root
    - mode: 440
    - template: jinja

dpkg.conf:
  file:
    - managed
    - name: /etc/dpkg/dpkg.cfg
    - source: salt://apt/dpkg.jinja2
    - user: root
    - group: root
    - mode: 440
    - template: jinja

{%- set backup = '/etc/apt/sources.list.salt-backup' %}
{%- if salt['file.file_exists'](backup) %}
apt.conf.bak:
  file:
    - rename
    - name: {{ backup }}
    - source: /etc/apt/sources.list
    - require_in:
      - file: apt
{%- endif %}

{#- make sure basic ubuntu keys are there #}
apt-key:
  file:
    - managed
    - name: {{ opts['cachedir'] }}/apt.gpg
    - source: salt://apt/key.gpg
    - user: root
    - group: root
    - mode: 440
  cmd:
    - wait
    - name: apt-key add {{ opts['cachedir'] }}/apt.gpg
    - watch:
      - file: apt-key

{#- minimum configuration of apt and make sure basic packages required by salt
    to work correctly (mostly for pkgrepo, but that aren't required dependencies
    are installed. #}
apt:
  file:
    - managed
    - name: /etc/apt/sources.list
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - contents: |
        # {{ salt['pillar.get']('message_do_not_modify') }}
        {{ salt['pillar.get']('apt:sources')|indent(8) }}
  {#- handle the case when dpkg is interrupted due to OOM:

      dpkg: unrecoverable fatal error, aborting:
        #012 fork failed: Cannot allocate memory
        #012E: Sub-process /usr/bin/dpkg returned an error code (2)

      salt.loaded.int.module.cmdmod: stderr: E: dpkg was interrupted,
      you must manually run 'dpkg --configure -a' to correct the problem. #}
  cmd:
    - run
    - name: dpkg --configure -a
  module:
    - wait
    - name: pkg.refresh_db
    - watch:
      - file: apt
      - file: apt.conf
    - require:
      - file: dpkg.conf
      - cmd: apt-key
      - cmd: apt
{%- set packages_blacklist = salt['pillar.get']('packages:blacklist', []) -%}
{%- set packages_whitelist = salt['pillar.get']('packages:whitelist', []) -%}
{%- if packages_blacklist or packages_whitelist %}
    - require_in:
    {%- if packages_blacklist %}
      - pkg: packages_blacklist
    {%- endif -%}
    {%- if packages_whitelist %}
      - pkg: packages_whitelist
    {%- endif -%}
{%- endif %}

{#- simple state, just keep the API as others used it #}
apt_sources:
  pkg:
    - installed
    - pkgs:
      - debconf-utils
      - python-apt
      - python-software-properties
    - require:
      - module: apt
  cmd:
    - wait
    - name: touch /etc/apt/sources.list
    - watch:
      - pkg: apt_sources
      - module: apt
{%- if salt['pillar.get']('apt:upgrade', False) %}
  module:
    - run
    - name: pkg.upgrade
    - upgrade: True
    - require:
      - module: apt
    - watch_in:
      - cmd: apt_sources
{%- endif %}

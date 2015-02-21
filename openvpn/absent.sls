{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- from "upstart/absent.sls" import upstart_absent with context -%}

{%- set prefix = '/etc/init/' -%}
{%- set upstart_files = salt['file.find'](prefix, name='openvpn-*.conf', type='f') -%}
    {%- for filename in upstart_files -%}
        {%- set instance = filename.replace(prefix + 'openvpn-', '').replace('.conf', '') %}

{{ upstart_absent('openvpn-' + instance) }}

/etc/openvpn/{{ instance }}:
  file:
    - absent
    - require:
      - service: openvpn-{{ instance }}
    {# /var/log/upstart/network-interface- #}

    {%- endfor %}
openvpn:
  pkg:
    - purged

/etc/default/openvpn:
  file:
    - absent
    - require:
      - pkg: openvpn

{%- for type in ('lib', 'run', 'log') %}
/var/{{ type }}/openvpn:
  file:
    - absent
{%- endfor %}

/etc/openvpn:
  file:
    - absent

{{ opts['cachedir'] }}/{{ salt['pillar.get']('openvpn:ca:name') }}.serial:
  file:
    - absent

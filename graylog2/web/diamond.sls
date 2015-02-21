{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{% set version = '0.20.6' %}

include:
  - diamond
  - mongodb.diamond
  - nginx.diamond
  - rsyslog.diamond

graylog2_web_diamond_resource:
  file:
    - accumulated
    - name: processes
    - filename: /etc/diamond/collectors/ProcessResourcesCollector.conf
    - require_in:
      - file: /etc/diamond/collectors/ProcessResourcesCollector.conf
    - text:
      - |
        [[graylog2-web]]
        cmdline = java.+\-Duser\.dir=/usr/local/graylog2\-web\-interface-{{ version }}

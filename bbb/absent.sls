libreoffice:
  pkg:
    - purged
  file:
    - absent
    - name: /etc/apt/sources.list.d/ppa.launchpad.net-libreoffice_libreoffice-4-0_ubuntu-precise.list
  cmd:
    - run
    - name: 'apt-key del 1378B444'
    - onlyif: apt-key list | grep -q 1378B444

kill_soffice:
  cmd:
    - run
    - name: kill -9 `pgrep '/usr/bin/soffice'` || true
    - onlyif: pgrep '/usr/bin/soffice'
  file:
    - absent
    - name: /var/run/bbb-openoffice-server.pid
    - require:
      - cmd: kill_soffice

{% for i in ('bigbluebutton', 'bbb-config', 'bbb-web', 'bbb-openoffice-headless', 'red5', 'bbb-record-core', 'bbb-freeswitch', 'bbb-apps', 'bbb-client', 'bbb-apps-sip', 'bbb-common', 'bbb-playback-presentation', 'bbb-apps-deskshare', 'bbb-apps-video') %}
{{ i }}:
  pkg:
    - purged
    - require:
      - file: kill_soffice
{% endfor %}

libffi5:
  pkg:
    - purged
    - require:
      - pkg: ruby1.9.2

ruby1.9.2:
  pkg:
    - purged

{% for i in ('ruby', 'ri', 'irb', 'erb', 'rdoc', 'gem') %}
/usr/bin/{{ i }}:
  file:
    - absent
{% endfor %}

/etc/apt/sources.list.d/bigbluebutton.list:
  file:
    - absent

/usr/local/bin/bbb-conf-wrap.sh:
  file:
    - absent

{%- set bbb_dir = opts['cachedir'] + "/bbb" -%}
redis_build_dir:
  file:
    - absent
    - name: {{ bbb_dir }}

tomcat6:
  pkg:
    - purged
    - name: tomcat6-common
    - require:
      - service: tomcat6
  service:
    - dead
    - name: tomcat6
  file:
    - absent
    - name: /etc/default/tomcat6
    - require:
      - pkg: tomcat6
  cmd:
    - run
    - name: sed -i '\:tomcat6:d' /etc/environment

/etc/tomcat6:
  file:
    - absent
    - require:
      - pkg: tomcat6

add_catalina_env:
  file:
    - absent
    - require:
      - pkg: tomcat6

/usr/share/tomcat6/shared:
  file:
    - absent

/usr/share/tomcat6/server:
  file:
    - absent

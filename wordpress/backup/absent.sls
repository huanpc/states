{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

backup-wordpress:
  file:
    - absent
    - name: /etc/cron.daily/backup-wordpress

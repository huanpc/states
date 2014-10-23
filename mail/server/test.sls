{#-
Copyright (c) 2013, Hung Nguyen Viet
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Author: Hung Nguyen Viet <hvnsweeting@gmail.com>
Maintainer: Hung Nguyen Viet <hvnsweeting@gmail.com>
-#}
{%- from 'cron/test.sls' import test_cron with context %}
include:
  - amavis
  - amavis.nrpe
  - amavis.diamond
  - amavis.clamav
  - clamav.nrpe
  - clamav.diamond
  - dovecot
  - dovecot.backup
  - dovecot.backup.nrpe
  - dovecot.diamond
  - dovecot.nrpe
  - mail.server.nrpe
  - openldap
  - openldap.diamond
  - openldap.nrpe
  - postfix.nrpe
  - postfix.diamond

{%- call test_cron() %}
- sls: amavis
- sls: amavis.nrpe
- sls: amavis.diamond
- sls: amavis.clamav
- sls: clamav.nrpe
- sls: clamav.diamond
- sls: dovecot
- sls: dovecot.backup
- sls: dovecot.backup.nrpe
- sls: dovecot.diamond
- sls: dovecot.nrpe
- sls: mail.server.nrpe
- sls: openldap
- sls: openldap.diamond
- sls: openldap.nrpe
- sls: postfix.nrpe
- sls: postfix.diamond
{%- endcall %}

test:
  monitoring:
    - run_all_checks
    - order: last

test_check_mail_stack:
  cmd:
    - run
    - name: /usr/lib/nagios/plugins/check_mail_stack.py
    - require:
      - sls: amavis
      - sls: clamav
      - sls: dovecot
      - sls: postfix
      - sls: openldap
      - sls: mail.server.nrpe

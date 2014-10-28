{#-
Copyright (c) 2014, Quan Tong Anh
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

Author: Quan Tong Anh <quanta@robotinfra.com>
Maintainer: Quan Tong Anh <quanta@robotinfra.com>
-#}
include:
  - bash
  - denyhosts
  - denyhosts.diamond
  - denyhosts.nrpe

{%- set fake_ip = '127.8.9.10' %}

fake_ssh_login:
  cmd:
    - run
    - name: |
        logger -p auth.info 'The {{ salt['pillar.get']('denyhosts:deny_threshold_root', 1) + 1 }} sshd below lines are generated by logger to test DenyHosts'
        for i in $(seq {{ salt['pillar.get']('denyhosts:deny_threshold_root', 1) + 1 }}); do logger -p auth.warning -t 'sshd[1234]:' 'Failed password for root from {{ fake_ip }} port 5678 ssh2'; done
    - require:
      - sls: bash

test:
  module:
    - run
    - name: service.restart
    - m_name: denyhosts
    - require:
      - cmd: fake_ssh_login
  cmd:
    - run
    - name: /usr/local/bin/denyhosts-unblock {{ fake_ip }}
    - require:
      - sls: denyhosts
      - module: test
  monitoring:
    - run_all_checks
    - order: last
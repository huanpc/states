:Copyrights: Copyright (c) 2013, Hung Nguyen Viet

             All rights reserved.

             Redistribution and use in source and binary forms, with or without
             modification, are permitted provided that the following conditions
             are met:

             1. Redistributions of source code must retain the above copyright
             notice, this list of conditions and the following disclaimer.

             2. Redistributions in binary form must reproduce the above
             copyright notice, this list of conditions and the following
             disclaimer in the documentation and/or other materials provided
             with the distribution.

             THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
             "AS IS" AND ANY EXPRESS OR IMPLIED ARRANTIES, INCLUDING, BUT NOT
             LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
             FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
             COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
             INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES(INCLUDING,
             BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
             LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
             CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
             LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
             ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
             POSSIBILITY OF SUCH DAMAGE.
:Authors: - Hung Nguyen Viet

Pillar
======

Mandatory
---------

Example::

  backup_server:
    address: 192.168.1.1
    fingerprint: 00:de:ad:be:ef:xx

backup_server:address
~~~~~~~~~~~~~~~~~~~~~

IP/Hostname of backup server.

backup_server:fingerprint
~~~~~~~~~~~~~~~~~~~~~~~~~

SSH fingerprint of backup SSH server.

How to get SSH fingerprint
~~~~~~~~~~~~~~~~~~~~~~~~~~

This is an example for getting github.com SSH fingerprint:: 
  
  ssh-keyscan github.com > /tmp/github.pub

Then run below command::
  
  ssh-keygen -lf /tmp/github.pub

Output is key's fingerprint::
  
  2048 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48 github.com (RSA)
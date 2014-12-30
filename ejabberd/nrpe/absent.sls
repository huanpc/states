{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Dang Tung Lam <lam@robotinfra.com>
Maintainer: Van Pham Diep <favadi@robotinfra.com>
-#}

{%- from 'nrpe/passive.jinja2' import passive_absent with context %}
{{ passive_absent('ejabberd') }}

/etc/nagios/nrpe.d/ejabberd-nginx.cfg:
  file:
    - absent

/etc/nagios/nrpe.d/postgresql-ejabberd.cfg:
  file:
    - absent

# -*- coding: utf-8 -*-

import logging

logger = logging.getLogger(__name__)


class _DontExistData(object):
    pass


def data():
    '''
    Return data specific for this minion required for monitoring.
    '''
    output = {
        'shinken_pollers': __salt__['pillar.get']('shinken_pollers', []),
        'roles': __salt__['pillar.get']('roles', []),
    }

    # figure how monitoring can reach this host
    if 'availabilityZone' in __salt__['grains.ls']():
        output['amazon_ec2'] = {
            'availability_zone': __salt__['grains.get']('availabilityZone'),
            'region':  __salt__['grains.get']('region')
        }
        output['ip_addrs'] = {
            'public': [__salt__['grains.get']('public-ipv4')],
            'private': [__salt__['grains.get']('privateIp')],
        }
    else:
        # for now, just use eth0
        output['ip_addrs'] = {
            'public': __salt__['network.ip_addrs']('eth0')
        }
        if not output['ip_addrs']['public']:
            # if nothing was found, just grab all IP address
            output['ip_addrs']['public'] = __salt__['network.ip_addrs']()
        output['ip_addrs']['private'] = output['ip_addrs']['public']

    # check monitoring_data pillar for extra values to return
    monitoring_data = __salt__['pillar.get']('monitoring_data', {})
    extra_data = {}
    for key_name in monitoring_data:
        try:
            key_type = monitoring_data[key_name]['type']
        except KeyError:
            logger.error("Missing type for '%s'", key_name)
            continue

        try:
            path = monitoring_data[key_name]['path']
        except KeyError:
            logger.error("Missing path for '%s'", key_name)
            continue

        if key_type == 'keys':
            extra_data[key_name] = __salt__['pillar.get'](path, {}).keys()
        elif key_type == 'exists':
            value = __salt__['pillar.get'](path, _DontExistData)
            if value == _DontExistData:
                extra_data[key_name] = False
            else:
                extra_data[key_name] = True
        else:
            logger.error()
    output['data'] = extra_data

    return output

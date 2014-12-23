# -*- coding: utf-8 -*-
'''
Control of SSH known_hosts entries
==================================

Manage the information stored in the known_hosts files.

.. code-block:: yaml

    github.com:
      ssh_known_hosts:
        - present
        - user: root
        - fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48

    example.com:
      ssh_known_hosts:
        - absent
        - user: root
'''

# Import python libs
import os


def present(
        name,
        user=None,
        fingerprint=None,
        key=None,
        port=None,
        enc=None,
        config=None,
        hash_hostname=True):
    '''
    Verifies that the specified host is known by the specified user

    On many systems, specifically those running with openssh 4 or older, the
    ``enc`` option must be set, only openssh 5 and above can detect the key
    type.

    :param name: The name of the remote host (e.g. "github.com")

    :param user: The user who owns the ssh authorized keys file to modify

    :param enc: Defines what type of key is being used, can be ed25519, ecdsa
                ssh-rsa or ssh-dss

    :param fingerprint: The fingerprint of the key which must be presented in
                        the known_hosts file

    :param port: optional parameter, denoting the port of the remote host,
                 which will be used in case, if the public key will be
                 requested from it. By default the port 22 is used.

    :param config: The location of the authorized keys file relative to the
                   user's home directory, defaults to ".ssh/known_hosts". If no
                   user is specified, defaults to "/etc/ssh/ssh_known_hosts".
                   If present, must be an absolute path when a user is not
                   specified.

    :param boolean hash_hostname: Hash all hostnames and addresses in the
                                  output. Default: ``True``
    '''
    ret = {'name': name,
           'changes': {},
           'result': None if __opts__['test'] else True,
           'comment': ''}

    if not user:
        config = config or '/etc/ssh/ssh_known_hosts'
    else:
        config = config or '.ssh/known_hosts'

    if not user and not os.path.isabs(config):
        comment = 'If not specifying a "user", specify an absolute "config".'
        ret['result'] = False
        return dict(ret, comment=comment)

    if __opts__['test']:
        if key and fingerprint:
            comment = 'Specify either "key" or "fingerprint", not both.'
            ret['result'] = False
            return dict(ret, comment=comment)
        elif key:
            if not enc:
                comment = 'Required argument "enc" if using "key" argument.'
                ret['result'] = False
                return dict(ret, comment=comment)
            result = __salt__['ssh.check_known_host'](user, name,
                                                      key=key,
                                                      config=config)
        elif fingerprint:
            result = __salt__['ssh.check_known_host'](user, name,
                                                      fingerprint=fingerprint,
                                                      config=config)
        else:
            comment = 'Arguments key or fingerprint required.'
            ret['result'] = False
            return dict(ret, comment=comment)
        if result == 'exists':
            comment = 'Host {0} is already in {1}'.format(name, config)
            ret['result'] = True
            return dict(ret, comment=comment)
        elif result == 'add':
            comment = 'Key for {0} is set to be added to {1}'.format(name,
                                                                     config)
            return dict(ret, comment=comment)
        else:  # 'update'
            comment = 'Key for {0} is set to be updated in {1}'.format(name,
                                                                       config)
            return dict(ret, comment=comment)

    result = __salt__['ssh.set_known_host'](user=user, hostname=name,
                                            fingerprint=fingerprint,
                                            key=key,
                                            port=port,
                                            enc=enc,
                                            config=config,
                                            hash_hostname=hash_hostname)
    if result['status'] == 'exists':
        return dict(ret,
                    Gcomment='{0} already exists in {1}'.format(name, config))
    elif result['status'] == 'error':
        return dict(ret, result=False, comment=result['error'])
    else:  # 'updated'
        if key:
            new_key = result['new']['key']
            return dict(ret,
                        changes={'old': result['old'], 'new': result['new']},
                        comment='{0}\'s key saved to {1} (key: {2})'.format(
                            name, config, new_key))
        else:
            fingerprint = result['new']['fingerprint']
            return dict(
                ret,
                changes={'old': result['old'], 'new': result['new']},
                comment='{0}\'s key saved to {1} (fingerprint: {2})'.format(
                    name, config, fingerprint))


def absent(name, user=None, config=None):
    '''
    Verifies that the specified host is not known by the given user

    :param name: The host name

    :param user: The user who owns the ssh authorized keys file to modify

    :param config: The location of the authorized keys file relative to the
                   user's home directory, defaults to ".ssh/known_hosts". If no
                   user is specified, defaults to "/etc/ssh/ssh_known_hosts".
                   If present, must be an absolute path when a user is not
                   specified.
    '''
    ret = {'name': name,
           'changes': {},
           'result': None if __opts__['test'] else True,
           'comment': ''}

    if not user:
        config = config or '/etc/ssh/ssh_known_hosts'
    else:
        config = config or '.ssh/known_hosts'

    if not user and not os.path.isabs(config):
        comment = 'If not specifying a "user", specify an absolute "config".'
        ret['result'] = False
        return dict(ret, comment=comment)

    known_host = __salt__['ssh.get_known_host'](user=user, hostname=name,
                                                config=config)
    if not known_host:
        return dict(ret, comment='Host is already absent')

    if __opts__['test']:
        comment = 'Key for {0} is set to be removed from {1}'.format(name,
                                                                     config)
        return dict(ret, comment=comment)

    rm_result = __salt__['ssh.rm_known_host'](user=user, hostname=name,
                                              config=config)
    if rm_result['status'] == 'error':
        return dict(ret, result=False, comment=rm_result['error'])
    else:
        return dict(ret,
                    changes={'old': known_host, 'new': None},
                    result=True,
                    comment=rm_result['comment'])

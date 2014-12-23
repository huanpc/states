# -*- coding: utf-8 -*-
'''
Manage RabbitMQ Users
=====================

Example:

.. code-block:: yaml

    rabbit_user:
        rabbitmq_user.present:
            - password: password
            - force: True
            - tags: administrator
            - perms:
              - '/':
                - '.*'
                - '.*'
                - '.*'
            - runas: rabbitmq
'''

# Import python libs
import logging

# Import salt libs
import salt.utils

log = logging.getLogger(__name__)


def __virtual__():
    '''
    Only load if RabbitMQ is installed.
    '''
    return salt.utils.which('rabbitmqctl') is not None


def present(name,
            password=None,
            force=False,
            tags=None,
            perms=(),
            runas=None):
    '''
    Ensure the RabbitMQ user exists.

    :param user name: User name
    :param string password: User's password, if one needs to be set
    :param boolean force: If user exists, forcibly change the password
    :param string tag: Optionally set user tags for user
    :param perms: A list of dicts with vhost keys and 3-tuple values
    :type perms: list of dict
    :param user runas: Name of the user to run the command
    '''

    ret = {'name': name, 'result': True, 'comment': '', 'changes': {}}
    result = {}

    user_exists = __salt__['rabbitmq.user_exists'](name, runas=runas)

    if user_exists and not force:
        ret['comment'] = 'User {0} already exists'.format(name)

    elif __opts__['test']:
        ret['result'] = None

        if not user_exists:
            ret['comment'] = 'User {0} is set to be created'
        elif force:
            ret['comment'] = 'User {0} is set to be updated'
        ret['comment'] = ret['comment'].format(name)

    else:
        changes = {'old': '', 'new': ''}

        # Get it into the correct format
        if tags and isinstance(tags, (list, tuple)):
            tags = ' '.join(tags)

        def _set_tags_and_perms(tags, perms):
            if tags:
                result.update(__salt__['rabbitmq.set_user_tags'](
                    name, tags, runas=runas)
                )
                changes['new'] += 'Set tags: {0}\n'.format(tags)
            for element in perms:
                for vhost, perm in element.items():
                    result.update(__salt__['rabbitmq.set_permissions'](
                        vhost, name, perm[0], perm[1], perm[2], runas)
                    )
                    changes['new'] += (
                        'Set permissions {0} for vhost {1}'
                    ).format(perm, vhost)

        if not user_exists:
            log.debug(
                "User doesn't exist - Creating")
            result = __salt__['rabbitmq.add_user'](
                name, password, runas=runas)

            _set_tags_and_perms(tags, perms)
        elif force:
            log.debug('User exists and force is set - Overriding')
            if password is not None:
                result = __salt__['rabbitmq.change_password'](
                    name, password, runas=runas)
                changes['new'] = 'New password has been set.\n'
            else:
                log.debug('Password is not set - Clearing password')
                result = __salt__['rabbitmq.clear_password'](
                    name, runas=runas)
                changes['old'] += 'Old password has been removed.\n'
            _set_tags_and_perms(tags, perms)
        else:
            log.debug('User exists, and force is not set - Abandoning')
            ret['comment'] = ('User {0} is not going to be'
                              ' modified').format(name)

        if 'Error' in result:
            ret['result'] = False
            ret['comment'] = result['Error']
        elif 'Added' in result:
            ret['comment'] = result['Added']
            ret['changes'] = changes
        elif 'Password Changed' in result:
            ret['comment'] = result['Password Changed']
            ret['changes'] = changes
        elif 'Password Cleared' in result:
            ret['comment'] = result['Password Cleared']
            ret['changes'] = changes

    return ret


def absent(name,
           runas=None):
    '''
    Ensure the named user is absent

    :param name: The name of the user to remove
    :param runas: User to run the command
    '''
    ret = {'name': name, 'result': True, 'comment': '', 'changes': {}}

    user_exists = __salt__['rabbitmq.user_exists'](name, runas=runas)

    if not user_exists:
        ret['comment'] = 'User {0} is not present'.format(name)
    elif __opts__['test']:
        ret['result'] = None
        if user_exists:
            ret['comment'] = 'Removing user {0}'.format(name)
    else:
        result = __salt__['rabbitmq.delete_user'](name, runas=runas)
        if 'Error' in result:
            ret['result'] = False
            ret['comment'] = result['Error']
        elif 'Deleted' in result:
            ret['comment'] = 'Deleted'
            ret['changes'] = {'new': '', 'old': name}

    return ret

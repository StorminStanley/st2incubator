#! /usr/bin/env python

import argparse
import json
import requests
import sys


def create_rule(url, rule):
    # check if rule with the same name exists
    existing_rule_id = _get_rule_id(url, rule)

    headers = {'created-from': 'Action: ' + __name__}
    # TODO: Figure out AUTH
    if existing_rule_id:
        sys.stderr.write('Updating existing rule %s\n' % existing_rule_id)
        put_url = '%s/%s' % (url, existing_rule_id)
        rule['id'] = existing_rule_id
        resp = requests.put(put_url, data=json.dumps(rule), headers=headers)
    else:
        sys.stderr.write('Creating new rule %s\n' % rule['name'])
        sys.stderr.write('url=%s, data=%s' % (url, json.dumps(rule)))
        resp = requests.post(url, data=json.dumps(rule), headers=headers)

    if resp.status_code not in [200, 201]:
        raise Exception('Failed creating rule in st2. status code: %s' % resp.status_code)


def _get_rule_id(base_url, rule):
    get_url = '%s/?name=%s' % (base_url, rule['name'])
    sys.stderr.write(get_url)
    resp = requests.get(get_url)
    if resp.status_code in [200]:
        if len(resp.json()) > 0:
            return resp.json()[0]['id']
    return None


def _get_st2_rules_url(base_url):
    if base_url.endswith('/'):
        return base_url + 'rules'
    else:
        return base_url + '/rules'


def main(args):
    parser = argparse.ArgumentParser(description='Create a rule to that release ' +
                                                 'st2client to pypi on a branch.')
    parser.add_argument('--branch', help='Branch to use.',
                        required=True)
    parser.add_argument('--st2-base-url', help='st2 base url.',
                        required=True)
    args = parser.parse_args()

    if args.branch in ['master']:
        sys.stderr.write('Master is not allowed branch for release.')
        sys.exit(1)

    if not args.st2_base_url:
        sys.stderr.write('st2 URL needed to create a rule.')
        sys.exit(2)

    rule_meta = {
        'name': 'st2_pkg_st2client_' + args.branch,
        'description': 'Release st2client to pypi on build completion.',
        'enabled': True,
        'trigger': {
            'type': 'core.st2.generic.actiontrigger'
        },
        'criteria': {
            'trigger.action_name': {
                'pattern': 'st2cd.st2_pkg_ubuntu14',
                'type': 'equals'
            },
            'trigger.parameters.branch': {
                'pattern': args.branch,
                'type': 'equals'
            },
            'trigger.parameters.environment': {
                'pattern': 'production',
                'type': 'equals'
            },
            'trigger.status': {
                'pattern': 'succeeded',
                'type': 'equals'
            }
        },
        'action': {
            'ref': 'st2cd.st2_pkg_st2client',
            'parameters': {
                'repo': '{{trigger.body.repository.clone_url}}'
                'branch': args.branch
            }
        }
    }

    try:
        create_rule(_get_st2_rules_url(args.st2_base_url), rule_meta)
        sys.stdout.write('Successfully created rule %s\n' % rule_meta['name'])
    except Exception as e:
        sys.stderr.write('Failed creating rule %s: %s\n' % (rule_meta['name'], str(e)))
        sys.exit(1)


if __name__ == '__main__':
    main(sys.argv)

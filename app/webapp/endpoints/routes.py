import os
import logging
from collections import defaultdict
from app.util import jsonify
from flask import (
    request,
    Blueprint,
    abort,
)

from app.lintblame import git
from app.lintblame import py

logger = logging.getLogger(__name__)

blueprint = Blueprint('endpoints', __name__)


def valid_target(path):
    ext = os.path.splitext(path)[1]
    return ext in ['.py', '.go', '.js', '.json']


def get_path_or_400():
    path = request.args.get('path')
    if not path:
        abort(400)
    if path.startswith('~'):
        path = os.path.expanduser(path)
    return path


def paths_or_400():
    joined_paths = request.args.get('paths')
    if not joined_paths:
        abort(400)
    split_paths = joined_paths.split(',')
    for i, p in enumerate(split_paths):
        if p[0] == '~':
            split_paths[i] = os.path.expanduser(p)
    return split_paths


@blueprint.route('/dumb')
def dumb_route():
    return jsonify({'success': True})


def get_path_targets(path):
    logger.info('get_path_targets')
    if os.path.isdir(path):
        contents = [os.path.join(path, i) for i in os.listdir(path)
                    if not i.startswith('.')]
        logger.info('contents: {0}'.format(contents))
        return [i for i in contents if valid_target(i)]
    else:
        if valid_target[path]:
            return [path]
        else:
            return []


@blueprint.route('/testpath')
def test_path():
    path = get_path_or_400()
    response = {
        'path': path,
        'exists': os.path.exists(path)
    }
    if response['exists']:
        response['dir'] = os.path.isdir(path)
        if request.args.get('branch'):
            response['targets'] = git.git_branch_files(path)
        else:
            response['targets'] = get_path_targets(path)

        git_branch = git.git_branch(path)
        if git_branch:
            response['branch'] = git_branch
            response['vcs'] = 'git'
            response['name'] = git.git_name()

    return jsonify(response)


def _get_results(path):
    result = {}
    with open(path, 'r') as f:
        result['lines'] = f.read().splitlines()
    result['blame'] = git.blame(path)
    result['issues'] = []
    if path.endswith('.py'):
        result['issues'] += py.pylint_issues(path)
        result['issues'] += py.pep8_issues(path)
        result['issues'] += py.pyflakes_issues(path)
    elif path.endswith('.js') or path.endswith('.json'):
        result['issues'] += py.jshint_issues(path)
    return result


@blueprint.route('/fullscan')
def fullscan():
    joined_paths = request.args.get('paths')
    if not joined_paths:
        abort(404)
    paths = joined_paths.split(',')
    response = defaultdict(dict)
    for p in paths:
        response[p] = _get_results(p)
    return jsonify(response)


@blueprint.route('/poll')
def poll_paths():
    request_paths = paths_or_400()
    branch_mode = request.args.get('branch')
    if branch_mode and branch_mode.lower() != 'false':
        poll_paths = [p for p in git.git_branch_files(request_paths[0])]
    else:
        logger.info('here!')
        poll_paths = get_path_targets(request_paths[0])

    since = float(int(request.args.get('since')) / 1000)
    response = {
        'changed': {}
    }
    for p in poll_paths:
        mod = os.path.getmtime(p)

        if mod > since:
            response['changed'][p] = _get_results(p)

    if branch_mode:
        response['delete'] = [i for i in request_paths if i not in poll_paths]
    return jsonify(response)

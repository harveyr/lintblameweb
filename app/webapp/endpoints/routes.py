import os
import time
import datetime
import logging
from collections import defaultdict
from app.util import jsonify, utc_ms
from flask import (
    render_template,
    request,
    flash,
    redirect,
    url_for,
    session,
    Blueprint,
    abort,
)

from app.lintblame import git
from app.lintblame import py

logger = logging.getLogger(__name__)

blueprint = Blueprint('endpoints', __name__)


def valid_target(path):
    name, ext = os.path.splitext(path)
    return ext in ['.py', '.go']

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

        elif response['dir']:
            contents = [os.path.join(path, i) for i in os.listdir(path)
                        if not i.startswith('.')]
            targets = [i for i in contents if valid_target(i)]
            response['contents'] = contents
            response['targets'] = targets

        else:
            if valid_target(path):
                response['targets'] = [path]
            else:
                response['targets'] = []

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
    if branch_mode:
        poll_paths = git.git_branch_files(request_paths[0])
    else:
        poll_paths = request_paths

    since = float(int(request.args.get('since')) / 1000)
    # since_date = datetime.datetime.fromtimestamp(since / 1000)
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

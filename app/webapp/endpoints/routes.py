import os
import logging
from collections import defaultdict
from ..util import jsonify
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

from app.lintblame import blame
from app.lintblame import py

logger = logging.getLogger(__name__)

blueprint = Blueprint('endpoints', __name__)


def valid_path(path):
    name, ext = os.path.splitext(path)
    return ext in ['.py', '.go']

def get_path_or_400():
    path = request.args.get('path')
    if not path:
        abort(400)
    if path.startswith('~'):
        path = os.path.expanduser(path)
    return path

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
        if response['dir']:
            contents = [os.path.join(path, i) for i in os.listdir(path)
                        if not i.startswith('.')]
            targets = [i for i in contents if valid_path(i)]
            response['contents'] = contents
            response['targets'] = targets
        else:
            if valid_path(path):
                response['targets'] = [path]
            else:
                response['targets'] = []

    return jsonify(response)

@blueprint.route('/fullscan')
def fullscan():
    joined_paths = request.args.get('paths')
    if not joined_paths:
        abort(404)
    paths = joined_paths.split(',')
    response = defaultdict(dict)
    for p in paths:
        response[p]['blame'] = blame.blame(p)
        response[p]['issues'] = defaultdict(dict)
        response[p]['issues']['pylint'] = py.pylint_issues(p)
    return jsonify(response)


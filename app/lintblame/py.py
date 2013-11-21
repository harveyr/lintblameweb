# https://bitbucket.org/logilab/pylint
from pylint.epylint import py_run as pylint_run
import re
import subprocess


PEP8_REX = re.compile(r'\w+:(\d+):(\d+):\s(\w+)\s(.+)$', re.MULTILINE)
PYLINT_REX = re.compile(r'^(\w):\s+(\d+),\s*(\d+):\s(.+)$', re.MULTILINE)
PYFLAKES_REX = re.compile(r'\w+:(\d+):\s(.+)$', re.MULTILINE)
JSHINT_REX = re.compile(r'\w+: line (\d+), col (\d+),\s(.+)$', re.MULTILINE)


def pylint_(path):
    """Returns pylint results."""
    print('linting path: {0}'.format(path))
    out, err = pylint_run(return_std=True, script=path)
    for line in out:
        print('line: {0}'.format(line))
    for line in err:
        print('line: {0}'.format(line))
    return out


def pylint(path):
    proc = subprocess.Popen(
        'pylint --output-format=text {}'.format(path),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        shell=True
    )
    out, err = proc.communicate()
    return out + err


def pylint_issues(path):
    hits = PYLINT_REX.findall(pylint(path))
    results = []
    for hit in hits:
        results.append({
            'code': hit[0],
            'line': hit[1],
            'column': hit[2],
            'message': hit[3],
            'reporter': 'Pylint',
        })
    return results


def pep8(path):
    """Returns pep8 results."""
    proc = subprocess.Popen(
        ['pep8', path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    out, err = proc.communicate()
    return out + err


def pep8_issues(path):
    hits = PEP8_REX.findall(pep8(path))
    results = []
    for hit in hits:
        results.append({
            'line': hit[0],
            'column': hit[1],
            'code': hit[2],
            'message': hit[3],
            'reporter': 'PEP8',
        })
    return results


def pyflakes(path):
    proc = subprocess.Popen(
        ['pyflakes', path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    out, err = proc.communicate()
    return out + err


def pyflakes_issues(path):
    raw = pyflakes(path)
    hits = PYFLAKES_REX.findall(raw)
    results = []
    for hit in hits:
        results.append({
            'line': hit[0],
            'column': '',
            'code': '',
            'message': hit[1],
            'reporter': 'Pyflakes'
        })
    return results


def jshint(path):
    proc = subprocess.Popen(
        ['jshint', path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    out, err = proc.communicate()
    return out + err


def jshint_issues(path):
    raw = jshint(path)
    hits = JSHINT_REX.findall(raw)
    results = []
    for hit in hits:
        results.append({
            'line': hit[0],
            'column': hit[1],
            'code': '',
            'message': hit[2],
            'reporter': 'JSHint',
        })
    return results

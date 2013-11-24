from nose import tools as nt
from app.lintblame import py


def test_pylint():
    path = __file__
    if path.endswith('.pyc'):
        path = path[:-1]
    results = py.pylint(__file__)

import os
import sys
import shlex
from subprocess import call


if not hasattr(sys, 'real_prefix'):
    print("Not in a virtualenv. Quitting.")
    sys.exit()

for p in ['.git', 'app']:
    if not os.path.exists(p):
        sys.exit("Run this from the top directory of the app. Quitting.")

base_dir = os.getcwd()
bower_dir = 'webapp/static/bower_components'
assert(os.path.exists(bower_dir))


def run(command, description=None):
    if description:
        print('')
        print(description)
    call(shlex.split(command))

run('pip install flask', 'Installing Flask...')

os.mkdir(bower_dir)
run('bower install underscore', 'Installing Underscore Bower package...')
run('bower install angular', 'Installing AngularJs Bower package...')
run('bower install angular-ui-router', 'Installing AngularUI Router Bower package...')
run('bower install bootstrap', 'Installing Bootstrap Bower package...')
run('bower install less', 'Installing Bootstrap Bower package...')


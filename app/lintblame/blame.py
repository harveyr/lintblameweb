import subprocess
import re
import os

BLAME_NAME_REX = re.compile(r'\(([\w\s]+)\d{4}')

def git_path(path):
    dir_ = path
    if os.path.isfile(path):
        dir_ = os.path.split(path)[0]
    proc = subprocess.Popen(
        ['git', 'rev-parse', '--show-toplevel'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=dir_
    )
    out, err = proc.communicate()
    if out:
        return out
    return None


def git_name():
    subprocess.check_output(["git", "config", "user.name"])


def blame(path):
    working_dir = os.path.split(path)[0]
    proc = subprocess.Popen(
        ['git', 'blame', path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=working_dir
    )
    out, err = proc.communicate()
    blame_lines = (out + err).splitlines()
    result = {}
    for i, line in enumerate(blame_lines):
        match = BLAME_NAME_REX.search(line)
        if match:
            result[i] = match.group(1).strip()
        else:
            result[i] = None
    return result



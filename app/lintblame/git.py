import subprocess
import re
import os

from app import util

BLAME_NAME_REX = re.compile(r'\(([\w\s]+)\d{4}')


def git_path(path):
    """Returns the top-level git path."""
    dir_ = path
    if os.path.isfile(path):
        dir_ = os.path.split(path)[0]
    proc = subprocess.Popen(
        ['git', 'rev-parse', '--show-toplevel'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=dir_
    )
    out = proc.communicate()[0]
    if out:
        return out.strip()
    return None


def git_name():
    return subprocess.check_output(["git", "config", "user.name"]).strip()


def git_branch(path):
    working_dir = path
    if not os.path.isdir(path):
        working_dir = os.path.split(path)[0]
    proc = subprocess.Popen(
        ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=working_dir
    )
    out, err = proc.communicate()
    if err:
        return None
    return out.strip()


def git_branch_files(path):
    path = util.path_dir(path)
    if not path:
        raise Exception("Bad path: {}".format(path))

    top_dir = git_path(path)

    proc = subprocess.Popen(
        ["git", "diff", "--name-only"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=top_dir
    )
    out = proc.communicate()[0]

    all_files = set(out.splitlines())

    branch = git_branch(path)
    if branch != 'master':
        proc = subprocess.Popen(
            ["git", "diff", "--name-only", "master..HEAD"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=path
        )
        out = proc.communicate()[0]
        all_files.update(out.splitlines())

    return [os.path.join(top_dir, i) for i in all_files if i]


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

#!/bin/bash -eu

CPYTHON_INTERPRETERS='cpython2 cpython3'
PYPY_INTERPRETERS='pypy2 pypy3'
PYTHON2_INTERPRETERS='cpython2 pypy2'


function run_tests()
{
    interpreters="$1"
    label="$2"

    for interpreter in ${interpreters}; do
        /opt/${interpreter}/bin/py.test /tests/ -m ${label}
    done
}

run_tests 'cpython2 cpython2 pypy2 pypy3' common
run_tests "${CPYTHON_INTERPRETERS}" cpython
run_tests "${PYPY_INTERPRETERS}" pypy
run_tests "${PYTHON2_INTERPRETERS}" python2


# coding: utf-8
import importlib
import sys

import pytest


@pytest.mark.common
@pytest.mark.parametrize('module', [
    'elasticsearch',
    'fastavro',
    'ipaddress',
    'networkx',
    'pymongo',
    'dateutil',
    'requests',
    'shapely',
    'tld',
    'tldextract',
])
def test_can_import_common_module(module):
    importlib.import_module(module)


@pytest.mark.cpython
@pytest.mark.parametrize('module', [
    'cartopy',
    'matplotlib',
    'pandas',
    'psycopg2',
    'seaborn',
    'snappy',
])
def test_can_import_cpython_module(module):
    import matplotlib as mpl
    mpl.use('Agg')
    importlib.import_module(module)


@pytest.mark.pypy
@pytest.mark.parametrize('module', [
    'psycopg2cffi',
])
def test_can_import_pypy_module(module):
    importlib.import_module(module)


@pytest.mark.python2
@pytest.mark.parametrize('module', [
    'matplotlib',
])
def test_can_import_python2_module(module):
    importlib.import_module(module)


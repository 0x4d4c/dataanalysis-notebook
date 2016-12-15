#!/bin/bash
set -eu

SRC='/usr/src'
INSTALL_BASE_PATH='/opt'

declare -A CPYTHON2=(['version']='2.7.12' ['kernelname']='cpython2' ['displayname']='Python (2.7)')
declare -A CPYTHON3=(['version']='3.5.2' ['kernelname']='cpython3' ['displayname']='Python (3.5)')
declare -A PYPY2=(['version']='2-v5.6.0' ['kernelname']='pypy2' ['displayname']='PyPy (2.7)')
declare -A PYPY3=(['version']='3.3-v5.5.0-alpha' ['kernelname']='pypy3' ['displayname']='PyPy (3.3)')


function install_kernel()
{   
    name="$1"
    displayname="$2"
    python="$3"
    pip="$4"
    ${pip} install ipykernel ipywidgets
    ${python} -m ipykernel install --name "${name}" --display-name "${displayname}"
}


function install_requirements()
{
    impl="$1"
    inst_path="$2"
    req_path='/usr/src/requirements'
    ${inst_path}/bin/pip install -r ${req_path}/common.txt
    [ -f ${req_path}/${impl:0:-1}.txt ] && ${inst_path}/bin/pip install -r ${req_path}/${impl:0:-1}.txt || true 
    [ -f ${req_path}/${impl}.txt ] && ${inst_path}/bin/pip install -r ${req_path}/${impl}.txt  || true
}


function install_cpython()
{
    version="$1"
    inst_path="${INSTALL_BASE_PATH}/cpython${version%%.*}"
    pkg_url="https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz"

    configure_flags=" \
        --enable-unicode=ucs4 \
        --prefix=${inst_path}/ \
        --with-ensurepip \
        --with-system-expat \
        LDFLAGS=-Wl,-rpath=${inst_path}/lib"
    curl -LSs ${pkg_url} | tar -xJC /usr/src/ -f-
    cd ${SRC}/Python-${version}
    ./configure --enable-shared ${configure_flags}
    make -j$(getconf _NPROCESSORS_ONLN)
    make install
    # install a statically linked python binary
    make distclean
    ./configure ${configure_flags}
    make -j$(getconf _NPROCESSORS_ONLN)
    make altbininstall
    cd - > /dev/null
    rm -rf ${SRC}/Python-${version}
    if [ ${version:0:1} -eq 3 ]; then
        ln -s ${inst_path}/bin/pip3 ${inst_path}/bin/pip
        ln -s ${inst_path}/bin/python3 ${inst_path}/bin/python
    fi
    ${inst_path}/bin/pip install --upgrade pip
    if [ ${version:0:1} -eq 2 ]; then
        kernelname="${CPYTHON2[kernelname]}"
        displayname="${CPYTHON2[displayname]}"
    elif [ ${version:0:1} -eq 3 ]; then
        kernelname="${CPYTHON3[kernelname]}"
        displayname="${CPYTHON3[displayname]}"
    fi
    install_kernel "${kernelname}" "${displayname}" ${inst_path}/bin/python ${inst_path}/bin/pip
    install_requirements ${kernelname} ${inst_path}
}


function install_pypy()
{
    version="$1"
    pkg_url="https://bitbucket.org/pypy/pypy/downloads/pypy${version}-linux64.tar.bz2"
    version="$(echo ${version} | sed 's/^3\.\(.*\)-alpha/\1/')"
    inst_path="${INSTALL_BASE_PATH}/pypy${version%-*}"

    curl -LSs ${pkg_url} | tar -xjC /tmp/ -f-

    mv /tmp/pypy${version}-linux64 ${inst_path}
    if [ ${version:0:1} -eq 3 ]; then
        ln -s ${inst_path}/bin/pip3 ${inst_path}/bin/pip
        ln -s ${inst_path}/bin/pypy3 ${inst_path}/bin/pypy
    fi
    ${inst_path}/bin/pypy -m ensurepip
    ${inst_path}/bin/pip install --upgrade pip
    if [ ${version:0:1} -eq 2 ]; then
        kernelname="${PYPY2[kernelname]}"
        displayname="${PYPY2[displayname]}"
    elif [ ${version:0:1} -eq 3 ]; then
        kernelname="${PYPY3[kernelname]}"
        displayname="${PYPY3[displayname]}"
    fi
    install_kernel "${kernelname}" "${displayname}" ${inst_path}/bin/pypy ${inst_path}/bin/pip
    install_requirements ${kernelname} ${inst_path}
}


function install_python()
{
    impl="$1"

    case "${impl}" in
        "cpython2") install_cpython "${CPYTHON2[version]}" ;;
        "cpython3") install_cpython "${CPYTHON3[version]}" ;;
        "pypy2")  install_pypy "${PYPY2[version]}" ;;
        "pypy3")  install_pypy "${PYPY3[version]}" ;;
        *)
            echo -e "Error: '${impl}' is an unsupported Python implementation!\n"
            print_usage
            return 1
            ;;
    esac
}

install_python cpython2
install_python cpython3
install_python pypy2
install_python pypy3


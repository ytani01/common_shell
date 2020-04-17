#
# tsecho {header_str} {str}
#
tsecho () {
    _HEADER=$1
    shift
    _STR=$*
    
    _DATESTR=`LANG=C date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "${_DATESTR} ${_HEADER}> $*"
}

#
# tsechoeval {header_string} {command_line}
#
tsechoeval () {
    _HEADER=$1
    shift
    _CMDLINE=$*
    tsecho ${_HEADER} ${_CMDLINE}

    eval $_CMDLINE
    _RESULT=$?

    if [ $_RESULT -ne 0 ]; then
        tsecho ${_HEADER} "ERROR:\$?=$_RESULT:$_CMDLINE" >&2
    fi
    return $_RESULT
}

#
# activateenv [env_dir]
#
activatevenv () {
    _PWD0=`pwd`
    # tsecho $0 "_PWD0=$_PWD0"

    if [ $# -gt 1 ]; then
        tsecho $0 "ERROR: too many arguments" >&2
        tsecho $0 "" >&2
        tsecho $0 "    usage: $0 [env_dir]" >&2
        tsecho $0 "" >&2
        return 1
    fi

    _VENVDIR=`pwd`

    if [ ! -z $1 ]; then
        _VENVDIR=$1

        tsechoeval $0 cd $_VENVDIR
        _RESULT=$?
        if [ $_RESULT -ne 0 ]; then
            return $_RESULT
        fi
    fi

    while [ ! -f ./bin/activate ]; do
        cd ..

        _VENVDIR=`pwd`
        tsecho $0 "_VENVDIR=${_VENVDIR}" >&2

        if [ $_VENVDIR = "/" ]; then
            tsecho $0 "ERROR: './bin/activate': no such file" >&2
            cd ${_PWD0}
            return 1
        fi
    done

    # tsecho $0 "_VENVDIR=$_VENVDIR"

    if [ ! -z "${VIRTUAL_ENV}" ]; then
        tsecho $0 "deactivate (VIRTUAL_ENV=${VIRTUAL_ENV})"
        deactivate
    fi

    tsechoeval $0 . ./bin/activate
    tsecho $0 "VIRTUAL_ENV=${VIRTUAL_ENV}"

    cd "$_PWD0"
    # tsecho $0 `pwd`
}

waitip () {
    if ! which ifconfig > /dev/null 2>&1 ; then
        tsecho $0 "ERROR: ifconfig: no such command" >&2
        return 1
    fi

    _IFCONFIG=`which ifconfig`
    # tsecho $0 $_IFCONFIG

    while true; do
        _IPADDR=`${_IFCONFIG} -a | sed -n -e '/127\.0\.0\.1/d' -e /169\.254\./d -e 's/^.*inet \([^ ]*\).*$/\1/p'`
        #tsecho $0 "_IPADDR=$_IPADDR"

        if [ `echo $_IPADDR | wc -l` -ne 0 ]; then
            echo $_IPADDR
            return 0
        fi
        tsecho $0 ".." >&2
        sleep 1
    done
}

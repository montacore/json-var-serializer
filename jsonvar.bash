#!/usr/bin/env bash


# Serialize bash variables to JSON output
# Created
# Author: Joh Nallie via Dave Eddy <john.t.nallie@gmail.com>
# Date July 24th 2026
# License: MIT
# Contributors:
# John Nallie <john.t.nallie@gmail.com>


_jv-usage() {
        local usage
        read -r -d '' usage <<-EOF
        Usage: jsonvar [-aev] [[name], ...]

        Serialize bash variables to JSON output
        
        Options
            -a      show all variable
            -e      show only exported variables
            -v      show only the valies of the variables
            -h      show this message and exit
        EOF
        echo "$usage"
}

_jv-json-encode-string() {
        local s=$1

        local LC_ALL=C
        local -A table=()

        local hex byte esc i

        for((i = 1; i < 0x20; i++)); do
            printf -v hex '02%x' "$i"
            printf -v byte '%b' "\\x$hex"
            printf -v esc '\\u%04x' "$i"
            table[$byte]=$esc
        done
        table[$'\b']='\b'
        table[$'\t']='\t'
        table[$'\n']='\n'
        table[$'\f']='\f'
        table[$'\r']='\r'
        table['\']='\\'
        table['"']='\"'

        #serialize the string
        local out=''

        local len=${#s}
        local c
        for((i = 0; i < len; i++)); do
            c=${s:i:1}
            esc=${table[$c]}

            if [[ -n $esc ]]; then
                # lookup table match for this btye
                out+=$esc
            else
                # no lookup table match, byte falls through
                out+=$c
            fi

            echo "$c"
        done
        printf "%s\n" "$out"

}

_jv-encode-variable() {
        local _jv_name=$1
        local -n _jv__jv_ref=$_jv_name
        case "${_jv_ref@a}" in
                *a*) # process indexed array
                        echo -n '['
                        local _jv_value _jv_i=0
                        for _jv_value in "${!_jv_ref[@]}"; do
                            ((_jv_i++))
                            _jv-json-encode-string "$_jv_value"
                            if ((i < ${_jv_ref[@]})); then
                                echo -n ','
                            fi
                        done
                        echo -n ']'
                        ;;
                *A*) # process associative array
                        echo -n '{'
                        local _jv_key _jv_value _jv_i=0
                        for _jv_key in "${!_jv_ref[@]}"; do
                                (((_jv_i++))
                                _jv_value=${_jv_ref[$_jv_key]}
                                
                                _jv-json-encode-string "$_jv_key"
                                echo -n ': '
                                _jv-json-encode-string "$_jv_value"
                                
                                if ((_jv_i < ${#_jv_ref[@]})); then
                                    echo -n ', '
                                fi
                        done
                        echo -n '}'
                        ;;
                *i*) # process integer
                        echo "$_jv_ref"
                        ;;
                *) # anything else, it's probably a string tbh
                        _jv-json-encode-string "$_jv_ref"
                        ;;
        esac

}

jsonvar() {
    local all='false'
    local exported='false'
    local _jv_value='false'

    local OPTIND OPTARG opt
    while getopts 'aevh' opt; do
        case "$opt" in
            a) all='true';;
            e) exported='true';;
            v) _jv_value='true';;
            h) _jv_usage; return 0;;
            *) _jv_usage <&2; return 2;;
        esac
    done
    shift "$((OPTIND - 1))"
    local -a variables
    if $all; then
        compgen -v -V variables
    elif
        compgen -e -V variables
    else
        variables=("$@")
        if ((${#variables[@]} == 0 )); do
                echo 'no variable detected' >&2
                _jv_usage
                return 2
        fi
    fi

    # loop through the variavles and format them
    echo "{"
    for var in "${variables[@]}"; do
        # "_jv_key":<_jv_value>

        # indent
}





#!/bin/bash

prefix="/opt/nginx"
# openssl_path="/data/openssl"
user_notation="@@@@"
f_use_bear=""

usage() {
    echo "Usage: $0 [-b] [-p prefix]"
    echo "Options:"
    echo "  -b: Use bear to build"
    echo "  -p prefix: Specify the installation prefix"
    exit 1
}

while getopts "bp:h" opt; do
    case $opt in
    b)
        f_use_bear="true"
        echo "$user_notation Use bear to build"
        ;;
    p)
        prefix=$OPTARG
        echo "$user_notation Use prefix $prefix"
        ;;
    h)
        usage
        ;;
    \?)
        echo "$user_notation Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done

CFLAGS="-pipe -W -Wall -Wpointer-arith -Wno-unused -g3"
export CFLAGS
# ./auto/configure --prefix=/opt/nginx --with-threads --with-http_ssl_module
# --with-openssl=$openssl_path \
./auto/configure \
    --prefix=$prefix \
    --with-threads \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    --with-http_v2_module

if [ $? -ne 0 ]; then
    echo "$user_notation configure failed"
    exit 1
fi

n_jobs=12
make_command="make -j$n_jobs"
defaultLiBearPath="/usr/lib/x86_64-linux-gnu/bear/libear.so"

if [ -n "$f_use_bear" ]; then
    if ! command -v bear &>/dev/null; then
        echo "$user_notation bear not found, use default make command"
    else
        if [[ ! -f "$defaultLiBearPath" ]]; then
            echo "$user_notation libear.so not found, please install it first"
            echo "$user_notation sudo apt install libear -y"
            exit 1
        fi
        make_command="bear -l $defaultLiBearPath $make_command"
    fi
fi

eval "$make_command"
if [ $? -ne 0 ]; then
    echo "$user_notation make failed"
    exit 1
fi
echo "$user_notation Congratulations! You have successfully built nginx."
echo "$user_notation Now you can run 'sudo make install' to install nginx to $prefix."
exit 0

if [ -d "$prefix" ]; then
    if [ "$(ls -A "$prefix")" ]; then
        echo "$user_notation Destination directory $prefix exists and not empty, delete it first"
        sudo rm -rf "$prefix"
    fi
fi

sudo make install
if [ $? -ne 0 ]; then
    echo "$user_notation make install failed"
    exit 1
fi
echo "$user_notation Congratulations! You have successfully installed nginx to $prefix."

#!/bin/bash

prefix="/opt/nginx"
openssl_path="/data/openssl"
user_notation="@@@@"

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

make -j12
if [ $? -ne 0 ]; then
    echo "$user_notation make failed"
    exit 1
fi
echo "$user_notation Congratulations! You have successfully built nginx."
echo "$user_notation Now you can run 'sudo make install' to install nginx to $prefix."
exit 0

if [ -d $prefix ]; then
    if [ "$(ls -A $prefix)" ]; then
        echo "$user_notation Destination directory $prefix exists and not empty, delete it first"
        sudo rm -rf $prefix
    fi
fi

sudo make install
if [ $? -ne 0 ]; then
    echo "$user_notation make install failed"
    exit 1
fi
echo "$user_notation Congratulations! You have successfully installed nginx to $prefix."

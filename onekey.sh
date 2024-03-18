#!/bin/bash

CFLAGS="-pipe -W -Wall -Wpointer-arith -Wno-unused -g3"
prefix="/opt/nginx"
patch_file="patch/nginx-1.9.2.patch"
checkout_tag="release-1.9.2"

git branch | grep "$checkout_tag"
if [ $? -ne 0 ]; then
    echo "Checking out to tag $checkout_tag"
    git checkout $checkout_tag
    if [ $? -ne 0 ]; then
        echo "git checkout failed"
        exit 1
    fi
else
    echo "Already checked out to tag $checkout_tag"

fi

export CFLAGS
# ./auto/configure --prefix=/opt/nginx --with-threads --with-http_ssl_module
./auto/configure --prefix=$prefix --with-threads
if [ $? -ne 0 ]; then
    echo "configure failed"
    exit 1
fi

# Check if need to apply patch
grep "CRYPT_DATA_INTERNAL_SIZE" src/os/unix/ngx_user.c
if [ $? -ne 0 ]; then
    if [ ! -f $patch_file ]; then
        echo "Patch file $patch_file does not exist"
        exit 1
    fi
    git apply $patch_file
    if [ $? -ne 0 ]; then
    	echo "Apply patch failed"
    	exit 1
    fi
else
    echo  "Patch already applied"
fi

make -j12
if [ $? -ne 0 ]; then
    echo "make failed"
    exit 1
fi
echo "Congratulations! You have successfully built nginx."
exit 0

if [ -d $prefix ]; then
    if [ "$(ls -A $prefix)" ]; then
	echo "Destination directory $prefix exists and not empty, delete it first"
	sudo rm -rf $prefix
    fi
fi

sudo make install
if [ $? -ne 0 ]; then
    echo "make install failed"
    exit 1
fi
echo "Congratulations! You have successfully installed nginx to $prefix."

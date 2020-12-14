#!/bin/bash
sudo apt-get install bison
mkdir ~/glibc-install
cd ~/glibc-install
if [ ! -f glibc-2.27.tar.gz ]; then
  wget http://ftp.gnu.org/gnu/glibc/glibc-2.27.tar.gz
fi
rm -rf glibc-2.27
tar -zxvf glibc-2.27.tar.gz
cd glibc-2.27
rm -rf build
mkdir build
cd build
../configure --disable-werror --prefix=/home/seanie/tmp/glibc
export CFLAGS="-U_FORTIFY_SOURCE -O2 -fno-stack-protector"
export CPPFLAGS="$CFLAGS"
make -j1
make install

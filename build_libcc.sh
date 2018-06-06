#!/usr/local/bin/bash

set -e

export BUILDROOT=`pwd`
set -x
ver=`uname -K`

svnlite co -r456719 svn://svn.freebsd.org/ports/head/www/chromium chromium
cd chromium
patch -p1  < ../chromium_make.diff
make configure DISABLE_LICENSES=1 DISABLE_VULNERABILITIES=yes
cd ..
git clone https://github.com/electron/libchromiumcontent.git
cd libchromiumcontent
git checkout 0e760628832e77f72b4975ae0bcae8bb74afbf9c
patch -p1  --ignore-whitespace < ../libchromiumcontent_111.diff
script/bootstrap
#61.0.3163.100
mv ../chromium/work/chromium-61.0.3163.100 src
patch -p1 --ignore-whitespace < ../libchromiumcontent_patches.diff
patch -p1 --ignore-whitespace  -d src/ < ../chromiumv1.diff
patch -p1 --ignore-whitespace  -d src/ < ../libchromiumcontent_bsd.diff
patch -p1 --ignore-whitespace  -d src/ < ../libchromiumcontent_v8.diff
rm patches/v8/025-cherry_pick_cc55747.patch*
script/update -t x64 --skip_gclient
script/build -c static_library -t x64
script/build -c ffmpeg -t x64
#script/build -c native_mksnapshot -t x64
script/create-dist -c static_library -t x64
#script/create-dist  -c native_mksnapshot -t x64

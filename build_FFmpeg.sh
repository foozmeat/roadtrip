#!/bin/sh

#  build_FFmpeg.sh
#  Road Trip
#
#  Created by James on 10/11/13.
#  Copyright (c) 2013 James Moore. All rights reserved.

set -e

FFMPEG="ffmpeg-2.1.1"

# brew install automake celt libtool  shtool yasm
# 

# Compile Lame
#  http://sourceforge.net/projects/lame/files/lame/
#  ./configure --prefix=/tmp/ffmpeg-build --disable-shared --enable-static --disable-decoder --disable-frontend



cd $HOME/Downloads
if [ ! -e ffmpeg-snapshot.tar.bz2 ]; then
	echo "Downloading ffmpeg-snapshot.tar.bz2"
	curl -O http://www.ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
else
	echo "Using ffmpeg-snapshot.tar.bz2"
fi

tar xfz ffmpeg-snapshot.tar.bz2

cd $FFMPEG

env CPPFLAGS="-I/tmp/ffmpeg-build/include" LDFLAGS="-L/tmp/ffmpeg-build/lib" ./configure --disable-shared --enable-static --disable-ffplay --disable-ffprobe --disable-ffserver --disable-doc --arch=x86_64 --enable-version3 --as=yasm --enable-runtime-cpudetect --extra-version=me.jmoore.road-trip --enable-pthreads --enable-postproc --enable-libmp3lame --enable-bzlib --enable-zlib --prefix=/tmp/ffmpeg-build

make
cd -
cp $HOME/Downloads/$FFMPEG/ffmpeg Road\ Trip/

echo "Cleaning up"
rm -rf $HOME/Downloads/ffmpeg
#! /bin/sh
#
# Build Mednafen from source on Windows 7 (with 32-bit or 64-bit msys2) or Linux (debian tested)
#
#
# This used to be complicated by Mednafen wanting zlib to be built with full
# 64-bit support when the stock msys2 version only came with *fake* 64-bit
# support, but that problem has since been fixed by the msys2 developers.
#
# See http://sourceforge.net/p/msys2/discussion/general/thread/a1073b9b/
#
#
# Requires the following packages for a 32-bit build environment ...
#   <current msys2-base>
#   pacman -S base-devel
#   pacman -S mingw-w64-i686-toolchain
#
# Requires the following packages for 32-bit Mednafen ...
#   pacman -S mingw-w64-i686-libsndfile
#   pacman -S mingw-w64-i686-SDL2
#
#
# Requires the following packages for a 64-bit build environment ...
#   <current msys2-base>
#   pacman -S base-devel
#   pacman -S mingw-w64-x86_64-toolchain
#
# Requires the following packages for 64-bit Mednafen ...
#   pacman -S mingw-w64-x86_64-libsndfile
#   pacman -S mingw-w64-x86_64-SDL2
#
#
# msys2 directory ...
#   <some-windows-dir>\msys2
#
# output directory ...
#   <some-windows-dir>\mednafen
#
# source directory ...
#   <some-windows-dir>\msys2\mednafen
#
#
# source files ...
#   <some-windows-dir>\msys2\mednafen\mednafen-1.27.1.tar.xz
#   <some-windows-dir>\msys2\mednafen\zlib-1.2.11.tar.gz
#
# patch files to add extra RAM ...
#   <some-windows-dir>\msys2\mednafen\mednafen-1.21.3-pce-480k-scd.patch
#   <some-windows-dir>\msys2\mednafen\mednafen-1.22.1-pcfx-8mb-ram.patch
#
# patch files ...
#   <some-windows-dir>\msys2\mednafen\mednafen-0.9.38.7.patch
#   <some-windows-dir>\msys2\mednafen\zlib-1.2.11-msys2-off64.patch

# Set OSNAME to "Linux", "Darwin", "FreeBSD" or something on Windows.
OSNAME=`uname`

TOPDIR=$(pwd)
echo TOPDIR is $TOPDIR

#---------------------------------------------------------------------------------
# Clean up the source & build directories?
#---------------------------------------------------------------------------------

if [ "${1}" = "clean" ] ; then
  if [ -e  build ] ; then
    rm -rf build
  fi
  if [ -e  mednafen ] ; then
    rm -rf mednafen
  fi
  exit 0
fi

#---------------------------------------------------------------------------------
# Check Prerequisites
#---------------------------------------------------------------------------------

## Test for executables
TestEXE()
{
  TEMP=`type $1`
  if [ $? != 0 ]; then
    echo "Error: $1 not installed";
    exit 1;
  fi
}

TestEXE "curl";

#---------------------------------------------------------------------------------
# Download the source package(s)
#---------------------------------------------------------------------------------

mkdir -p archive
cd archive

if [ ! -e mednafen-1.27.1.tar.xz ]; then
  curl -L -O -R http://mednafen.fobby.net/releases/files/mednafen-1.27.1.tar.xz
fi

# if [ ! -e zlib-1.2.11.tar.gz ]; then
#   curl -L -O -R http://zlib.net/zlib-1.2.11.tar.gz
# fi

cd ..

#---------------------------------------------------------------------------------
# Install the required libraries
#---------------------------------------------------------------------------------

if [ "$OSTYPE" = "msys" ] ; then
  pacman -S --noconfirm --needed mingw-w64-$HOSTTYPE-libsndfile mingw-w64-$HOSTTYPE-SDL2
else
  echo To successfully build on any linux or any other *nix variant, you need
  echo to make sure echo that some prerequisite development libraries/packages
  echo are installed.
  echo On debian, those packages are ...
  echo       build-essential
  echo       pkg-config
  echo       libasound2-dev
  echo       libsdl2-dev
  echo       libsndfile1-dev
  echo       zlib1g-dev
  echo If you are not building on debian, then you will have to figure out
  echo what those packages are called on your particular *nix OS.
fi

#---------------------------------------------------------------------------------
# Unpack and patch Mednafen
#---------------------------------------------------------------------------------

PrepareSource()
{
  if [ -e  mednafen ] ; then
    rm -rf mednafen
  fi

  tar -xvJf archive/mednafen-1.27.1.tar.xz

  cd mednafen

  # Boost the PCE SysCard3 RAM from 192KB to 384KB (plus 2MB Arcade Card).
  #
  # sed -r -i "s/0x68/0x50/g"             src/pce/huc.cpp
  # sed -r -i "s/24 \* 8192/48 \* 8192/g" src/pce/huc.cpp
  # sed -r -i "s/8192 \* 24/8192 \* 48/g" src/pce/huc.cpp

  patch -p 1 -i ../patch/mednafen-1.27.1-pce-448k-scd.patch

  # Boost the PC-FX RAM from 2MB to 8MB.
  #
  # sed -r -i "s/1FFFFF/7FFFFF/g"   src/pcfx/mem-handler.inc
  # sed -r -i "s/1FFFFF/7FFFFF/g"   src/pcfx/pcfx.cpp
  # sed -r -i "s/200000/800000/g"   src/pcfx/pcfx.cpp
  # sed -r -i "s/, 21/, 23/g"       src/pcfx/pcfx.cpp
  # sed -r -i "s/2048 \*/8192 \*/g" src/pcfx/pcfx.cpp

  patch -p 1 -i ../patch/mednafen-1.27.1-pcfx-8mb-ram.patch

# Not needed anymore, fixed in mednafen
#
#  patch -p 1 -i ../patch/mednafen-1.21.3-tgfx-scd-fix.patch

  # Apply the PCE & PC-FX debugger "improvements".

  patch -p 1 -i ../patch/mednafen-1.27.1-new-6x9-font.patch
  patch -p 1 -i ../patch/mednafen-1.27.1-justify-main.patch
  patch -p 1 -i ../patch/mednafen-1.27.1-justify-rest.patch
  patch -p 1 -i ../patch/mednafen-1.27.1-arrange-pcfx.patch
  patch -p 1 -i ../patch/mednafen-1.27.1-expand-debug.patch
  patch -p 1 -i ../patch/mednafen-1.27.1-expand-watch.patch
  patch -p 1 -i ../patch/mednafen-1.27.1-expand-dblog.patch

  patch -p 1 -i ../patch/mednafen-1.27.1-dump-to-file.patch
  patch -p 1 -i ../patch/mednafen-1.27.1-disassembler.patch

  patch -p 1 -i ../patch/mednafen-1.27.1-visualise-sat.patch

  patch -p 1 -i ../patch/mednafen-1.27.1-ted2-1mb-ram.patch

# patch -p 1 -i ../patch/mednafen-mingw-v10.patch

  patch -p 1 -i ../patch/mednafen-1.27.1-mswin.patch

  # msys2's tar doesn't create the "include/mednafen" directory as a symlink like
  # it should, so just copy all the patched source files over manually.

  if [ "$OSTYPE" = "msys" ] ; then
    cp -a -f src/* include/mednafen/
  fi

  cd ..

  exit 1;
}

if [ ! -d mednafen ] ; then
  PrepareSource
fi

#---------------------------------------------------------------------------------
# Setup the toolchain for linux
#---------------------------------------------------------------------------------

# OUTPUTDIR=$(cygpath $(cygpath -m /)../)mednafen
#
# echo OUTPUTDIR is $OUTPUTDIR

#---------------------------------------------------------------------------------
# Configure Mednafen
#---------------------------------------------------------------------------------

# Compiling on Windows (mingw/cygwin) requires that this configure is invoked
# from a relative path and not an absolute path. Linux doesn't care.

export SOURCEDIR=../../mednafen

if [ "$OSTYPE" = "msys" ] ; then
export OUTPUTDIR=$TOPDIR/../../bin/mednafen
else
export OUTPUTDIR=$TOPDIR/bin
fi

mkdir -p $OUTPUTDIR
export PATH=$OUTPUTDIR:$PATH

export BUILDTEMP=$TOPDIR/build
export MDFNBUILD=$TOPDIR/build/mednafen

rm -rf $BUILDTEMP

mkdir -p $MDFNBUILD
cd $MDFNBUILD

# Run ./configure --help for a nice list of Mednafen's options.
#
#	CPPFLAGS 32-bit: -O2 -fomit-frame-pointer -march=i686 -mtune=pentium3
#	CPPFLAGS 64-bit: -O2 -fomit-frame-pointer -mtune=amdfam10

# These defines were needed when we had to compile our own version of zlib.
#
# export CPPFLAGS=-D_LARGEFILE64_SOURCE=1\ -D_LFS64_LARGEFILE=1

# export CPPFLAGS=-DUNICODE=1\ -D_UNICODE=1
# export LDFLAGS=-static-libstdc++

if [ "$OSTYPE" = "msys" ] ; then
  EXTRACONFIG=--disable-alsa\ --disable-jack\ --enable-threads=win32
else
  EXTRACONFIG=
fi

#  --disable-nls
#  --disable-rpath

$SOURCEDIR/configure     \
  --prefix=$OUTPUTDIR    \
  --bindir=$OUTPUTDIR    \
  $EXTRACONFIG           \
  --disable-apple2       \
  --disable-gb           \
  --disable-gba          \
  --disable-lynx         \
  --disable-md           \
  --disable-nes          \
  --disable-ngp          \
  --disable-pce-fast     \
  --disable-sms          \
  --disable-snes         \
  --disable-snes-faust   \
  --disable-ss           \
  --disable-ssfplay      \
  --enable-pce           \
  --enable-pcfx          \
  --enable-psx           \
  --enable-vb            \
  --enable-wswan

export CPPFLAGS=

echo "Mednafen configuration completed."

#---------------------------------------------------------------------------------
# Build zlib and install it into the mednafen build tree
#---------------------------------------------------------------------------------
# 
# ZLIB_PKG=zlib-1.2.11
# 
# if [ -e  $BUILDTEMP/$ZLIB_PKG ]; then
#   rm -rf $BUILDTEMP/$ZLIB_PKG
# fi
# 
# cd $BUILDTEMP
# 
# tar -xvzf ../$ZLIB_PKG.tar.gz
# 
# cd $ZLIB_PKG
# 
# patch -p1 < ../../zlib-1.2.11-msys2-off64.patch
# 
# ./configure               \
#   --prefix=$MDFNBUILD     \
#   --libdir=$MDFNBUILD/src \
#   --shared
# 
# make 2>&1 | tee zlib_make.log
# 
# if [ $? != 0 ]; then
#   echo "Error: building zlib";
#   exit 1;
# fi
# 
# make install 2>&1 | tee zlib_install.log
# 
# if [ $? != 0 ]; then
#   echo "Error: installing zlib into the mednafen build directory";
#   exit 1;
# fi
# 
# # Change the mednafen makefile to use the local library.
# 
# # sed -r -i "s/ -lz / libz.a /g" $MDFNBUILD/src/Makefile
# 
# echo "Mednafen zlib library built."

#---------------------------------------------------------------------------------
# Build Mednafen
#---------------------------------------------------------------------------------

cd $MDFNBUILD

make --jobs=$(nproc) $MAKE_FLAGS 2>&1 | tee mednafen_make.log

if [ $? != 0 ]; then
  echo "Error: building mednafen";
  exit 1;
fi

make install 2>&1 | tee mednafen_install.log

if [ $? != 0 ]; then
  echo "Error: installing mednafen";
  exit 1;
fi

#---------------------------------------------------------------------------------
# Copy the support DLL files (only on Windows)
#---------------------------------------------------------------------------------

if [ "$OSTYPE" = "msys" ] ; then

  # Shrink the executable.

  strip $OUTPUTDIR/mednafen.exe

  # Copy the msys2 DLLs to the destination directory.

  if [ "$HOSTTYPE" = "i686" ] ; then
    DLLDIR=/mingw32/bin
    cp -p $DLLDIR/libgcc_s_dw2-1.dll  $OUTPUTDIR/
  else
    DLLDIR=/mingw64/bin
    cp -p $DLLDIR/libgcc_s_seh-1.dll  $OUTPUTDIR/
  fi

  cp -p $DLLDIR/libFLAC-8.dll       $OUTPUTDIR/
  cp -p $DLLDIR/libiconv-2.dll      $OUTPUTDIR/
  cp -p $DLLDIR/libogg-0.dll        $OUTPUTDIR/
  cp -p $DLLDIR/libsndfile-1.dll    $OUTPUTDIR/
  cp -p $DLLDIR/libspeex-1.dll      $OUTPUTDIR/
  cp -p $DLLDIR/libstdc++-6.dll     $OUTPUTDIR/
  cp -p $DLLDIR/libvorbis-0.dll     $OUTPUTDIR/
  cp -p $DLLDIR/libvorbisenc-2.dll  $OUTPUTDIR/
  cp -p $DLLDIR/libwinpthread-1.dll $OUTPUTDIR/
  cp -p $DLLDIR/sdl2-config         $OUTPUTDIR/
  cp -p $DLLDIR/SDL2.dll            $OUTPUTDIR/
  cp -p $DLLDIR/zlib1.dll           $OUTPUTDIR/

fi

cd ../../

echo "Mednafen build completed sucsessfully"
exit 0

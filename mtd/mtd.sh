#!/bin/bash
 
#+--------------------------------------------------------------------------------------------
#|Description:  This shell script used to download lzo,zlib,mtd-utils source code
#|              and cross compile it for arm Linux, all is static cross compile.
#+--------------------------------------------------------------------------------------------
 
 
PRJ_PATH=`pwd`
CROSS=arm-none-linux-gnueabi-
HOST=arm-none-linux-gnueabi

CC=${CROSS}gcc
AR=${CROSS}ar
LD=${CROSS}ld
STRIP=${CROSS}strip
NM=${CROSS}nm
RANLIB=${CROSS}ranlib
OBJDUMP=${CROSS}objdump
 
 
export CC=${CC}
export AR=${AR}
export LD=${LD}
export STRIP=${STRIP}
export NM=${NM}
export RANLIB=${RANLIB}
export OBJDUMP=${OBJDUMP}
 
 
LZO="lzo-2.04"
ZLIB="zlib-1.2.8"
E2FSPROGS="e2fsprogs-1.39"

 
 
function decompress_packet()
{
   echo "+----------------------------------------+"
   echo "|  Decompress $1 now"  
   echo "+----------------------------------------+"
 
 
   if [ `ls $1 | grep "tar.bz2"` ] ; then
       set -x
       tar -xjf $1
       set +x
   fi
 
 
   if [ `ls $1 | grep "tar.gz"` ] ; then
       set -x
       tar -xzf $1
       set +x
   fi
}
 
 
echo "+----------------------------------------+"
echo "|  Cross compile $LZO now "  
echo "+----------------------------------------+"
 
 
# Download lzo source code packet
if [ ! -s $LZO.tar.gz ] ; then
   wget http://www.oberhumer.com/opensource/lzo/download/$LZO.tar.gz
fi
 
 
# Decompress lzo source code packet
if [ ! -d $LZO ] ; then
    decompress_packet $LZO.tar.*
fi
 
 
# Cross compile lzo
cd  $LZO
if [ ! -s src/.libs/liblzo*.a ] ; then
   unset LDFLAGS
   ./configure  --host=$HOST --enable-static --disable-shared CC=${CROSS}gcc AR=${AR} LD=${LD} \
   NM=${NM} RANLIB=${RANLIB} STRIP="${STRIP}" OBJDUMP=${OBJDUMP}
   make
fi
cd  -
 
 
echo "+----------------------------------------+"
echo "|  Cross compile $ZLIB now "  
echo "+----------------------------------------+"
# Download zlib source code packet
if [ ! -s $ZLIB.tar* ] ; then
   wget http://www.zlib.net/$ZLIB.tar.gz
   #wget http://www.imagemagick.org/download/delegates/$ZLIB.tar.bz2
fi
 
 
# Decompress zlib source code packet
if [ ! -d $ZLIB ] ; then
    decompress_packet $ZLIB.tar.*
fi
 
 
#Cross compile zlib
cd  $ZLIB
if [ ! -s libz.a ] ; then
    unset LDFLAGS
    ./configure  --static 
    make
fi
cd  -


echo "+----------------------------------------+"
echo "|  Cross compile E2fsprogs now "  
echo "+----------------------------------------+"
 
 
if [ ! -s $E2FSPROGS.tar.* ] ; then 
  wget http://nchc.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/1.39/$E2FSPROGS.tar.gz
fi
 
# download mtd-utils source code
if [ ! -d  $E2FSPROGS ] ; then
	decompress_packet $E2FSPROGS.tar.*
fi
 
cd e2fsprogs-1.39
if [ ! -s lib/libe2p.a ] ; then
    unset LDFLAGS
	./configure --host=${HOST} CC=${CROSS}gcc
    make
fi
cd -

echo "+----------------------------------------+"
echo "|  Cross compile mtd-utils now "  
echo "+----------------------------------------+"
 
 
if [ -s mtd-utils.tar.* ] ; then
    decompress_packet mtd-utils.tar.*
fi
 
# download mtd-utils source code
if [ ! -d  mtd-utils ] ; then
   git clone git://git.infradead.org/mtd-utils.git
fi
 
#Add the CROSS tool in file mtd-utils/common.mk
head -1 mtd-utils/common.mk | grep "CROSS=arm-none-linux-gnueabi-"

if [ 0 != $? ] 
then
   echo "Modify file mtd-utils/common.mk"
   sed -i -e 1i"CROSS=arm-none-linux-gnueabi-" mtd-utils/common.mk
fi

cd mtd-utils
  unset LDFLAGS
  export CFLAGS="-DWITHOUT_XATTR -I$PRJ_PATH/$ZLIB -I$PRJ_PATH/e2fsprogs/lib -I$PRJ_PATH/$LZO/include"
  export ZLIBLDFLAGS=-L$PRJ_PATH/$ZLIB
  export UUIDLDFLAGS=-L$PRJ_PATH/$E2FSPROGS/lib/
  export LZOLDFLAGS=-L$PRJ_PATH/$LZO/src/.libs/
  export LDFLAGS=-static
  make
cd -


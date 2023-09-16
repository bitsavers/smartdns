#!/usr/bin/env sh

apk update && apk add perl make coreutils tar pkgconfig dpkg binutils

# OpenSSL compile
# https://wiki.openssl.org/index.php/Compilation_and_Installation#Configuration
# $ ./Configure LIST
# linux-aarch64
# linux-alpha-gcc
# linux-aout
# linux-arm64ilp32
# linux-armv4
# linux-c64xplus
# linux-elf
# linux-generic32
# linux-generic64
# linux-ia64
# linux-mips32
# linux-mips64
# linux-ppc
# linux-ppc64
# linux-ppc64le
# linux-sparcv8
# linux-sparcv9
# linux-x32
# linux-x86
# linux-x86-clang
# linux-x86_64
# linux-x86_64-clang
# linux32-s390x
# linux64-loongarch64
# linux64-mips64
# linux64-riscv64
# linux64-s390x
# linux64-sparcv9
mkdir -p /workdir/openssl/build
cd /workdir/openssl
if [ "$ARCH" == "mipsel" ] || [ "$ARCH" == "mips" ] ; then
	OPENSSL_ARCH="linux-mips32"
	OPENSSL_ARGS="-DBROKEN_CLANG_ATOMICS"
elif [ "$ARCH" == "mips64el" ] || [ "$ARCH" == "mips64" ] ; then
	OPENSSL_ARCH="linux-generic64"
	OPENSSL_ARGS=""
elif [ "$ARCH" == "powerpc" ] ; then
	OPENSSL_ARCH="linux-ppc"
	OPENSSL_ARGS="-DBROKEN_CLANG_ATOMICS"
elif [ "$ARCH" == "powerpc64" ] ; then
	OPENSSL_ARCH="linux-generic64"
	OPENSSL_ARGS=""
elif [ "$ARCH" == "powerpc64le" ] ; then
	OPENSSL_ARCH="linux-ppc64le"
	OPENSSL_ARGS=""
elif [ "$ARCH" == "arm" ] ; then
	OPENSSL_ARCH="linux-armv4"
	OPENSSL_ARGS="-DBROKEN_CLANG_ATOMICS"
elif [ "$ARCH" == "arm64" ] ; then
	OPENSSL_ARCH="linux-aarch64"
	OPENSSL_ARGS=""
elif [ "$ARCH" == "riscv64" ] ; then
	OPENSSL_ARCH="linux64-riscv64"
	OPENSSL_ARGS=""
elif [ "$ARCH" == "x86" ] ; then
	OPENSSL_ARCH="linux-x86"
	OPENSSL_ARGS=""
elif [ "$ARCH" == "x86_64" ] ; then
	OPENSSL_ARCH="linux-x86_64"
	OPENSSL_ARGS=""
else
	OPENSSL_ARCH="linux-$ARCH"
	OPENSSL_ARGS=""
fi
perl ./Configure ${OPENSSL_ARCH} no-tests ${OPENSSL_ARGS} --prefix=/workdir/openssl/build 
make all -j$(nproc)

cd /workdir
export CFLAGS="-I /workdir/openssl/build/include -I /workdir/openssl/include"
export LDFLAGS="-s -Wl,--build-id=sha1 -L /workdir/openssl/build/lib"
sh ./package/build-pkg.sh --platform debian --arch all --filearch $ARCH-debian --static --outputdir /workdir/build
sh ./package/build-pkg.sh --platform linux --arch all --filearch $ARCH-linux --static --outputdir /workdir/build
sh ./package/build-pkg.sh --platform openwrt --arch all --filearch $ARCH-openwrt --static --outputdir /workdir/build
sh ./package/build-pkg.sh --platform optware --arch all --filearch $ARCH-optware --static --outputdir /workdir/build
cp ./src/smartdns /workdir/build/smartdns-$ARCH -a

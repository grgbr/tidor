#!/bin/bash -e

scriptdir=$(dirname $(realpath $0))
topdir=$(dirname $scriptdir)
outdir=$(make -p -C $topdir | awk -F ':= ' '/^OUTDIR/ { print $2 }')
outdir=$(realpath $outdir)
platform=$(make --no-print-directory -C $topdir show-platform)
stagingdir=$outdir/${platform/-//}/staging

toolchain_target_dir=$(make -p -C $topdir | \
                       awk -F ':= ' '/^XTCHAIN_TARGET_DIR/ { print $2 }')
toolchain_host_dir=$(make -p -C $topdir | \
                     awk -F ':= ' '/^XTCHAIN_HOST_DIR/ { print $2 }')

exec env PATH="$toolchain_target_dir/bin:$toolchain_host_dir/bin:$PATH" \
         PKG_CONFIG="$toolchain_host_dir/bin/pkg-config" \
         PKG_CONFIG_LIBDIR="$toolchain_target_dir/usr/lib/pkgconfig" \
         PKG_CONFIG_PATH="$stagingdir/lib/pkgconfig" \
         PKG_CONFIG_SYSROOT_DIR="$stagingdir" \
         AUTOCONF="$toolchain_host_dir/bin/autoconf" \
         AUTORECONF="$toolchain_host_dir/bin/autoreconf" \
         AUTOHEADER="$toolchain_host_dir/bin/autoheader" \
         AUTOM4TE="$toolchain_host_dir/bin/autom4te" \
         AUTOMAKE="$toolchain_host_dir/bin/automake" \
         ACLOCAL="$toolchain_host_dir/bin/aclocal" \
         LIBTOOLIZE="$toolchain_host_dir/bin/libtoolize" \
         LIBTOOL="$toolchain_host_dir/bin/libtool" \
         $*

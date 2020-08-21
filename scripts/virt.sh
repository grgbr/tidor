#!/bin/sh -e

board=va38x
flavour=devel

make BOARD:="$board" FLAVOUR:="$flavour" all

qemu_opts='-machine vexpress-a9
           -smp 4
           -m size=1G
           -nographic
           -netdev socket,listen=localhost:10000,id=eth0
           -netdev socket,listen=localhost:10001,id=eth1
           -device virtio-net-device,netdev=eth0
           -device virtio-net-device,netdev=eth1'

dir=${TMPDIR:-/tmp/$USER}/${board}_${flavour}

mkdir -p $dir
truncate --size=8G $dir/mmc
cat scripts/mmc.parts | sfdisk $dir/mmc

# Root partition mkfs
start_sect=$(sfdisk --list \
                    --output NAME,START \
                    $dir/mmc | \
             sed -n '/^ROOT/s/ROOT[[:blank:]]\+\(.*\)/\1/p')
dd if=out/$board/$flavour/root.sqfs \
   of=$dir/mmc obs=512 seek=$start_sect conv=notrunc

# Config partition mkfs
if [ ! -f "$dir/config.e4fs" ]; then
	start_sect=$(sfdisk --list \
	                    --output NAME,START \
	                    $dir/mmc | \
	             sed -n '/^CONFIG/s/CONFIG[[:blank:]]\+\(.*\)/\1/p')
	sect_nr=$(sfdisk --list \
	                 --output NAME,SECTORS \
	                 $dir/mmc | \
	          sed -n '/^CONFIG/s/CONFIG[[:blank:]]\+\(.*\)/\1/p')
	sect_size=$(sfdisk --list $dir/mmc | \
	            sed -n '/^Sector size/s/[^:]\+:[[:blank:]]\+\([0-9]\+\).*/\1/p')
	truncate --size=$(((sect_nr * sect_size) / 1024))K $dir/config.e4fs
	env MKE2FS_CONFIG=scripts/mke2fs.conf mke2fs -F -T config -L CONFIG -c $dir/config.e4fs
	dd if=$dir/config.e4fs \
	   of=$dir/mmc obs=512 seek=$start_sect conv=notrunc
fi

if [ "$1" = "ram" ]; then
	exec qemu-system-arm $qemu_opts \
	                     -drive if=sd,file="$dir/mmc",format=raw \
	                     -kernel out/$board/$flavour/zImage \
	                     -initrd out/$board/$flavour/root.initramfs \
	                     -dtb out/$board/$flavour/linux.dtb \
	                     -append "rdinit=/sbin/init console=ttyAMA0"
else
	exec qemu-system-arm $qemu_opts \
	                     -drive if=sd,file="$dir/mmc",format=raw \
	                     -kernel out/$board/$flavour/zImage \
	                     -dtb out/$board/$flavour/linux.dtb \
	                     -append "root=/dev/mmcblk0p2 rootfstype=squashfs ro rootwait console=ttyAMA0"
fi

sudo iozone -p -S $(($(getconf LEVEL3_CACHE_SIZE) / 1024)) -L $(getconf LEVEL1_DCACHE_LINESIZE) -B -i 0 -i 1 -i 2 -i 4 -n 32k -g 8m -a

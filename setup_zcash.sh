#!/bin/bash

declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/fedora-release]=dnf
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get

for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        apt=${osInfo[$f]}
        break
    fi
done

echo Package manager: $apt

if [ $apt = "yum" ] || [ $apt = "dnf" ]; then
    # nheqminer
    sudo $apt install -y git cmake @development-tools boost-devel "gcc-c++"
else
    # nheqminer
    sudo $apt install -y git cmake build-essential libboost-all-dev
    # beignet
    sudo $apt install -y \
        cmake pkg-config python ocl-icd-dev libegl1-mesa-dev ocl-icd-opencl-dev \
        libdrm-dev libxfixes-dev libxext-dev "llvm-3.6-dev" "clang-3.6" \
        "libclang-3.6-dev" libtinfo-dev libedit-dev zlib1g-dev
fi

mkdir zec
cd zec

# nheqminer setup
rm -rf ./nheqminer
git clone -b Linux https://github.com/nicehash/nheqminer.git
cd nheqminer/cpu_xenoncat/Linux/asm/
sh ./assemble.sh
cd ../../../Linux_cmake/nheqminer_cpu
cmake .
make -j$(nproc)
cd ../../../

cat > start.sh <<- EOM
#!/bin/bash

trap "trap - TERM && kill -9 -- -$$" INT TERM EXIT

./nheqminer/Linux_cmake/nheqminer_cpu/nheqminer_cpu -l us1-zcash.flypool.org:3333 -u t1KBPmuei8cKRKCXPUtLhXyuNmkVqd9sK1X -t $(nproc) &

sleep infinity
EOM

chmod +x start.sh


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
    # zogminer
    sudo $apt install -y \
        git pkgconfig automake autoconf ncurses-devel python wget vim-common \
        gtest-devel gcc "gcc-c++" libtool patch opencl-headers mesa-libGL-devel
else
    # nheqminer
    sudo $apt install -y git cmake build-essential libboost-all-dev
    # beignet
    sudo $apt install -y \
        cmake pkg-config python ocl-icd-dev libegl1-mesa-dev ocl-icd-opencl-dev \
        libdrm-dev libxfixes-dev libxext-dev "llvm-3.6-dev" "clang-3.6" \
        "libclang-3.6-dev" libtinfo-dev libedit-dev zlib1g-dev
    # zogminer
    sudo $apt install -y \
        build-essential pkg-config libc6-dev m4 "g++-multilib" \
        autoconf libtool ncurses-dev unzip git python \
        zlib1g-dev wget bsdmainutils automake opencl-headers \
        mesa-common-dev

    # setup beignet
    rm -rf ./beignet
    git clone git://anongit.freedesktop.org/beignet
    cd beignet
    git checkout "Release_v1.3.1"
    mkdir build
    cd build
    cmake ../
    make -j$(nproc)
    make utest -j$(nproc)
    sudo make install
    cd ../../
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

# zogminer setup
rm -rf ./zogminer
git clone https://github.com/nginnever/zogminer.git
cd zogminer
./zcutil/fetch-params.sh
./zcutil/build.sh -j$(nproc)
cd ../

cat > start.sh <<- EOM
#!/bin/bash

trap "trap - TERM && kill -9 -- -$$" INT TERM EXIT

./nheqminer/Linux_cmake/nheqminer_cpu/nheqminer_cpu -l us1-zcash.flypool.org:3333 -u t1KBPmuei8cKRKCXPUtLhXyuNmkVqd9sK1X -t $(nproc) &

./zogminer/src/zcash-miner -G -stratum="stratum+tcp://us1-zcash.flypool.org:3333" -user=t1KBPmuei8cKRKCXPUtLhXyuNmkVqd9sK1X &

sleep infinity
EOM

chmod +x start.sh


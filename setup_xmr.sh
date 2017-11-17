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
    # xmr-stak-cpu
    sudo $apt install -y gcc gcc-c++ hwloc-devel libmicrohttpd-devel openssl-devel cmake
else
    # xmr-stak-cpu
    sudo $apt install -y libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev
fi

mkdir xmr
cd xmr

# xmr-stak-cpu setup
rm -rf xmr-stak-cpu
git clone https://github.com/fireice-uk/xmr-stak-cpu.git
cd xmr-stak-cpu

cat > donate-level.h <<- EOM
#pragma once
constexpr double fDevDonationLevel = 0.0;
EOM
cmake . -DMICROHTTPD_ENABLE=OFF
make -j$(nproc) install
cd ../

cat > config.txt <<- EOM
"cpu_threads_conf" :
[
$(for (( i=1; i<=$(nproc); i++ )); do echo '{ "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : '$(($i - 1))' },'; done)
],
"use_slow_memory" : "warn",
"nicehash_nonce" : false,
"aes_override" : null,
"use_tls" : false,
"tls_secure_algo" : true,
"tls_fingerprint" : "",
"pool_address" : "xmr-us-east1.nanopool.org:14444",
"wallet_address" : "4ApJyxddzmmQ383MUX6QiMXFVBWjn3q9u3uPbh3d3NVfPSKgvSYFM1JVfK8rJqUwA4Td3rjnYd3ZA6dRUYLVzzoQN1nDZ76.default/camca96@gmail.com",
"pool_password" : "x",
"call_timeout" : 10,
"retry_time" : 10,
"giveup_limit" : 0,
"verbose_level" : 4,
"h_print_time" : 60,
"daemon_mode" : true,
"output_file" : "",
"httpd_port" : 0,
"prefer_ipv4" : true,
EOM

cat > start.sh <<- EOM
#!/bin/bash

trap "trap - TERM && kill -9 -- -$$" INT TERM EXIT

./xmr-stak-cpu/bin/xmr-stak-cpu

sleep infinity
EOM

chmod +x start.sh


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

if [ "$apt" = "yum" ] || [ "$apt" = "dnf" ]; then
    sudo $apt install -y gcc gcc-c++ hwloc-devel openssl-devel cmake
elif [ "$apt" = "apt-get" ]; then
    sudo $apt install -y libssl-dev cmake build-essential libhwloc-dev
else
    sudo xbps-install -Sy base-devel libhwloc-devel libressl-devel cmake
fi

# xmr-stak setup
rm -rf xmr-stak
git clone https://github.com/fireice-uk/xmr-stak.git
cd xmr-stak

cat > xmrstak/donate-level.hpp <<- EOM
#pragma once
constexpr double fDevDonationLevel = 0.0;
EOM
cmake . -DMICROHTTPD_ENABLE=OFF -DCMAKE_BUILD_TYPE=Release -DCPU_ENABLE=ON -DOpenCL_ENABLE=OFF -DCUDA_ENABLE=OFF
make -j$(nproc) install
cd ../

cat > xmr-stak/bin/config.txt <<- EOM
"pool_list" :
[
	{"pool_address" : "xmr-us-east1.nanopool.org:14444", "wallet_address" : "4ApJyxddzmmQ383MUX6QiMXFVBWjn3q9u3uPbh3d3NVfPSKgvSYFM1JVfK8rJqUwA4Td3rjnYd3ZA6dRUYLVzzoQN1nDZ76.`hostname`/camca96@gmail.com", "pool_password" : "x", "use_nicehash" : false, "use_tls" : false, "tls_fingerprint" : "", "pool_weight" : 1 },
],
"currency" : "monero",
"call_timeout" : 10,
"retry_time" : 30,
"giveup_limit" : 0,
"verbose_level" : 4,
"print_motd" : false,
"h_print_time" : 120,
"aes_override" : null,
"use_slow_memory" : "warn",
"tls_secure_algo" : true,
"daemon_mode" : true,
"flush_stdout" : false,
"output_file" : "log.txt",
"httpd_port" : 0,
"http_login" : "",
"http_pass" : "",
"prefer_ipv4" : true,
EOM

cat > xmr-stak/bin/cpu.txt <<- EOM
"cpu_threads_conf" :
[
$(for (( i=1; i<=`grep '^core id' /proc/cpuinfo |sort -u|wc -l`; i++ )); do echo '{ "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : '$(($i - 1))' },'; done)
],
EOM

cat > xmr-stak/bin/start.sh <<- EOM
#!/bin/bash

case "\$1" in
    -d|--daemon)
        \$0 < /dev/null &> /dev/null & disown
        exit 0
        ;;
    *)
        ;;
esac

sudo ./xmr-stak

EOM

chmod +x xmr-stak/bin/start.sh

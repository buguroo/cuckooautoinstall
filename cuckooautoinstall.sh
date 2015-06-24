#!/bin/bash

cat <<EO
┌─────────────────────────────────────────────────────────┐
│                CuckooAutoInstall 0.2                    │
│ David Reguera García - Dreg <dreguera@buguroo.com>      │
│ David Francos Cuartero - XayOn <dfrancos@buguroo.com>   │
│            Buguroo Offensive Security - 2015            │
└─────────────────────────────────────────────────────────┘
EO

source /etc/os-release
source build_functions.bash

SUDO="sudo"
TMPDIR=$(mktemp -d)
RELEASE=$(lsb_release -cs)
ORIG_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
VIRTUALBOX_REP="deb http://download.virtualbox.org/virtualbox/debian $RELEASE contrib"

declare -a packages
packages["debian"]="python-pip python-sqlalchemy mongodb python-bson python-dpkt python-jinja2 python-magic python-gridfs python-libvirt python-bottle python-pefile python-chardet git build-essential autoconf automake libtool dh-autoreconf libcurl4-gnutls-dev libmagic-dev python-dev tcpdump libcap2-bin virtualbox dkms python-pyrex"
packages["ubuntu"]="python-pip python-sqlalchemy mongodb python-bson python-dpkt python-jinja2 python-magic python-gridfs python-libvirt python-bottle python-pefile python-chardet git build-essential autoconf automake libtool dh-autoreconf libcurl4-gnutls-dev libmagic-dev python-dev tcpdump libcap2-bin virtualbox dkms python-pyrex"

[[ $UID != 0 ]] && {
    type -f $SUDO || {
        echo "You're not root and you don't have $SUDO, please become root or install $SUDO before executing $0"
        exit
    }
} || {
    $SUDO=""
}

[[ ! -e /etc/debian_version ]] && {
    echo "This script currently works only on debian-based (debian, ubuntu...) distros"
    exit 1
}

clone_repos(){
    git clone https://github.com/akheron/jansson
    git clone https://github.com/plusvic/yara
}

clone_cuckoo(){
    cd /home/cuckoo/
    $SUDO git clone https://github.com/cuckoobox/cuckoo
    $SUDO chown -R cuckoo:cuckoo cuckoo
    cd $TMPDIR
}

create_hostonly_iface(){
    $SUDO vboxmanage hostonlyif create
    $SUDO iptables -A FORWARD -o eth0 -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT
    $SUDO iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    $SUDO iptables -A POSTROUTING -t nat -j MASQUERADE
    $SUDO sysctl -w net.ipv4.ip_forward=1
}

create_cuckoo_user(){
    $SUDO adduser  --disabled-password -gecos "" cuckoo
    $SUDO usermod -G vboxusers cuckoo
}

setcap(){
    $SUDO setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
}

fix_django_version(){
    cd /home/cuckoo/
    python -c "import django; from distutils.version import LooseVersion; import sys; sys.exit(LooseVersion(django.get_version()) <= LooseVersion('1.5'))" && { 
        egrep -i "templates = \(.*\)" cuckoo/web/web/settings.py || sed -i '/TEMPLATE_DIRS/{ N; s/.*/TEMPLATE_DIRS = \( \("templates"\),/; }' cuckoo/web/web/settings.py
    }
    cd $TMPDIR
}

enable_mongodb(){
    cd /home/cuckoo/
    sed -i '/\[mongodb\]/{ N; s/.*/\[mongodb\]\nenabled = yes/; }' cuckoo/conf/reporting.conf
    cd $TMPDIR
}

build_jansson(){
    # Not cool =(
    cd ${TMPDIR}/jansson
    autoreconf -vi
    ./configure
    make
    make check
    $SUDO make install
    $SUDO autoreconf -i --force
    cd ${TMPDIR}
}

build_yara(){
    cd ${TMPDIR}/yara
    ./bootstrap.sh
    $SUDO autoreconf -i --force
    ./configure --enable-cuckoo --enable-magic
    make
    $SUDO make install
    cd yara-python/
    $SUDO python setup.py install
    cd ${TMPDIR}
}



cd ${TMPDIR}
echo ${VIRTUALBOX_REP} |$SUDO tee /etc/apt/sources.list.d/virtualbox.list
wget -O - https://www.virtualbox.org/download/oracle_vbox.asc | $SUDO apt-key add -
$SUDO apt-get update
$SUDO apt-get install -y  ${packages["${RELEASE}"]}
$SUDO apt-get -y install 
$SUDO pip install -r ${ORIG_DIR}/requirements.txt

clone_repos
clone_cuckoo
build_jansson
build_yara
create_hostonly_iface
create_cuckoo_user
setcap
fix_django_version
enable_mongodb

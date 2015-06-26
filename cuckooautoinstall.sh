#!/bin/bash

source /etc/os-release

# Configuration variables. You can override these in config.
SUDO="sudo"
TMPDIR=$(mktemp -d)
RELEASE=$(lsb_release -cs)
CUCKOO_USER="cuckoo"
CUSTOM_PKGS=""
ORIG_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
VOLATILITY_URL="http://downloads.volatilityfoundation.org/releases/2.4/volatility-2.4.tar.gz"
VIRTUALBOX_REP="deb http://download.virtualbox.org/virtualbox/debian $RELEASE contrib"
CUCKOO_REPO='https://github.com/cuckoobox/cuckoo'
YARA_REPO="https://github.com/plusvic/yara"
JANSSON_REPO="https://github.com/akheron/jansson"

LOG=$(mktemp)
UPGRADE=false

declare -a packages
declare -a python_packages 

packages["debian"]="python-pip python-sqlalchemy mongodb python-bson python-dpkt python-jinja2 python-magic python-gridfs python-libvirt python-bottle python-pefile python-chardet git build-essential autoconf automake libtool dh-autoreconf libcurl4-gnutls-dev libmagic-dev python-dev tcpdump libcap2-bin virtualbox dkms python-pyrex"
packages["ubuntu"]="python-pip python-sqlalchemy mongodb python-bson python-dpkt python-jinja2 python-magic python-gridfs python-libvirt python-bottle python-pefile python-chardet git build-essential autoconf automake libtool dh-autoreconf libcurl4-gnutls-dev libmagic-dev python-dev tcpdump libcap2-bin virtualbox dkms python-pyrex"
python_packages=(pymongo django pydeep maec py3compat lxml cybox distorm3 pycrypto)
log_icon="\e[31m✓\e[0m"


# -

print_copy(){
cat <<EO
┌─────────────────────────────────────────────────────────┐
│                CuckooAutoInstall 0.2                    │
│ David Reguera García - Dreg <dreguera@buguroo.com>      │
│ David Francos Cuartero - XayOn <dfrancos@buguroo.com>   │
│            Buguroo Offensive Security - 2015            │
└─────────────────────────────────────────────────────────┘
EO
}

check_viability(){
    [[ $UID != 0 ]] && {
        type -f $SUDO || {
            echo "You're not root and you don't have $SUDO, please become root or install $SUDO before executing $0"
            exit
        }
    } || {
        SUDO=""
    }

    [[ ! -e /etc/debian_version ]] && {
        echo  "This script currently works only on debian-based (debian, ubuntu...) distros"
        exit 1
    }
}

print_help(){
    cat <<EOH
Usage: $0 [--verbose|-v] [--help|-h] [--upgrade|-u]

    --verbose   Print output to stdout instead of temp logfile
    --help      This help menu
    --upgrade   Use newer volatility, yara and jansson versions (install from source)

EOH
    exit 1
}

setopts(){
    optspec=":hvu-:"
    while getopts "$optspec" optchar; do
        case "${optchar}" in
            -)
                case "${OPTARG}" in
                    help) print_help ;;
                    upgrade) UPGRADE=true ;;
                    verbose) LOG=/dev/stdout ;;
                esac;;
            h) print_help ;;
            v) LOG=/dev/stdout;;
            u) UPGRADE=true;;
        esac
    done
}


run_and_log(){
    echo -e "${log_icon} ${2}"
    $1 &> ${LOG}
}

clone_repos(){
    git clone ${JANSSON_REPO}
    git clone ${YARA_REPO}
}

create_cuckoo_user(){
    $SUDO adduser  --disabled-password -gecos "" ${CUCKOO_USER}
    $SUDO usermod -G vboxusers ${CUCKOO_USER}
}

clone_cuckoo(){
    cd ~${CUCKOO_USER}
    $SUDO git clone $CUCKOO_REPO
    $SUDO chown -R ${CUCKOO_USER}:${CUCKOO_USER} cuckoo
    cd $TMPDIR
}

create_hostonly_iface(){
    $SUDO vboxmanage hostonlyif create
    $SUDO iptables -A FORWARD -o eth0 -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT
    $SUDO iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    $SUDO iptables -A POSTROUTING -t nat -j MASQUERADE
    $SUDO sysctl -w net.ipv4.ip_forward=1
}

setcap(){
    $SUDO setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
}

fix_django_version(){
    cd ~${CUCKOO_USER}
    python -c "import django; from distutils.version import LooseVersion; import sys; sys.exit(LooseVersion(django.get_version()) <= LooseVersion('1.5'))" && { 
        egrep -i "templates = \(.*\)" cuckoo/web/web/settings.py || $SUDO sed -i '/TEMPLATE_DIRS/{ N; s/.*/TEMPLATE_DIRS = \( \("templates"\),/; }' cuckoo/web/web/settings.py
    }
    cd $TMPDIR
}

enable_mongodb(){
    cd ~${CUCKOO_USER}
    $SUDO sed -i '/\[mongodb\]/{ N; s/.*/\[mongodb\]\nenabled = yes/; }' cuckoo/conf/reporting.conf
    cd $TMPDIR
}

build_jansson(){
    # Not cool =(
    cd ${TMPDIR}/jansson
    autoreconf -vi --force
    ./configure
    make
    make check
    $SUDO make install
    cd ${TMPDIR}
}

build_yara(){
    cd ${TMPDIR}/yara
    ./bootstrap.sh
    $SUDO autoreconf -vi --force
    ./configure --enable-cuckoo --enable-magic
    make
    $SUDO make install
    cd yara-python/
    $SUDO python setup.py install
    cd ${TMPDIR}
}

build_volatility(){
    wget $VOLATILITY_URL
    tar xvf volatility-2.4.tar.gz
    cd volatility-2.4/
    $SUDO python setup.py build
    $SUDO python setup.py install
}

pip(){
    # TODO: Calling upgrade here should be optional.
    # Unless we make all of this into a virtualenv, wich seems like the
    # correct way to follow
    for package in ${@}; do $SUDO pip install ${package} --upgrade; done
}

prepare_virtualbox(){
    cd ${TMPDIR}
    echo ${VIRTUALBOX_REP} |$SUDO tee /etc/apt/sources.list.d/virtualbox.list
    wget -O - https://www.virtualbox.org/download/oracle_vbox.asc | $SUDO apt-key add -
}

install_packages(){
    $SUDO apt-get update
    $SUDO apt-get install -y ${packages["${RELEASE}"]}
    $SUDO apt-get install -y $CUSTOM_PKGS
    $SUDO apt-get -y install 
}

# Install packages
run_and_log prepare_virtualbox "Getting virtualbox repo ready"
run_and_log install_packages "Installing packages ${packages[$RELEASE]}"

# Install python packages
run_and_log pip ${python_packages[@]} "Installing python packages: ${python_packages[@]}"

# Create user and clone repos
run_and_log create_cuckoo_user "Creating cuckoo user"
run_and_log clone_repos "Cloning repositories"
run_and_log clone_cuckoo "Cloning cuckoo repository"

# Build packages
run_and_log build_jansson "Building and installing jansson"
run_and_log build_yara "Building and installing yara"
run_and_log install_volatility "Installing volatility"

# Configuration
run_and_log fix_django_version "Fixing django problems on old versions"
run_and_log enable_mongodb "Enabling mongodb in cuckoo"

# Networking (latest, because sometimes it crashes...)
run_and_log create_hostonly_iface "Creating hostonly interface for cuckoo"
run_and_log setcap "Setting capabilities"


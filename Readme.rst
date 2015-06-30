About CuckooAutoinstall
=======================

`Cuckoo Sandbox <http://www.cuckoosandbox.org/>`_. auto install script

What is Cuckoo Sandbox?
-----------------------

Cuckoo Sandbox is a malware analysis system.

What does that mean? 
--------------------

It means that you can throw any suspicious file at it and get a report with
details about the file's behavior inside an isolated environment.

We created this at `Buguroo Offensive Security <http://www.buguroo.com>`_ initially to make the painful
cuckoo installation quicker, easier and painless

Supported systems
-----------------

Most of this script is not distro dependant (tough of course you've got to run
it on GNU/Linux), but package installation, at this moment supports only
debian derivatives.

Also, given that we use the propietary virtualbox version (most of the time OSE
edition doesn't fulfill our needs), this script requires that they've got
a debian repo in `Virtualbox Downloads <http://downloads.virtualbox.org>`_ 
for your distro. Forcing the distro in config file should make it work in
unsupported ones.

Authors
-------

`David Reguera García - Dreg <http://github.com/David-Reguera-Garcia-Dreg>`_ - `dreguera@buguroo.com <mailto:dreguera@buguroo.com>`_

`David Francos Cuartero - XayOn <http://github.com/Xayon>`_ - `dfrancos@buguroo.com <mailto:dfrancos@buguroo.com>`_


Quickstart guide
================

* Execute the script: *bash cuckooautoinstall.sh*

.. image:: /../screenshots/cuckooautoinstall.png?raw=true


The script does accept a configuration file in the form of a simple
bash script with options such as:

::

    SUDO="sudo"
    TMPDIR=$(mktemp -d)
    RELEASE=$(lsb_release -cs)
    CUCKOO_USER="cuckoo"
    CUSTOM_PKGS=""
    ORIG_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"   )" && pwd   )
    VOLATILITY_URL="http://downloads.volatilityfoundation.org/releases/2.4/volatility-2.4.tar.gz"
    VIRTUALBOX_REP="deb http://download.virtualbox.org/virtualbox/debian $RELEASE contrib"
    CUCKOO_REPO='https://github.com/cuckoobox/cuckoo'
    YARA_REPO="https://github.com/plusvic/yara"
    JANSSON_REPO="https://github.com/akheron/jansson"

    LOG=$(mktemp)
    UPGRADE=false

You can override any of these variables in the config file.

It accepts parameters

::

    ┌─────────────────────────────────────────────────────────┐
    │                CuckooAutoInstall 0.2                    │
    │ David Reguera García - Dreg <dreguera@buguroo.com>      │
    │ David Francos Cuartero - XayOn <dfrancos@buguroo.com>   │
    │            Buguroo Offensive Security - 2015            │
    └─────────────────────────────────────────────────────────┘
    Usage: cuckooautoinstall.sh [--verbose|-v] [--help|-h] [--upgrade|-u]

        --verbose   Print output to stdout instead of temp logfile
        --help      This help menu
        --upgrade   Use newer volatility, yara and jansson versions (install from source)

For most setups, --upgrade is recommended always.

* Add a password (as root) for the user *'cuckoo'* created by the script

::

    passwd cuckoo

* Create the virtual machines `http://docs.cuckoosandbox.org/en/latest/installation/guest/`
  or import virtual machines

::

  VBoxManage import virtual_machine.ova

* Add to the virtual machines with HostOnly option using vboxnet0

::

  vboxmanage modifyvm “virtual_machine" --hostonlyadapter1 vboxnet0

* Configure cuckoo (`http://docs.cuckoosandbox.org/en/latest/installation/host/configuration/` )

* Execute cuckoo 

::

  cd ~cuckoo/cuckoo
  python cuckoo.py

.. image:: /../screenshots/github%20cuckoo%20working.png?raw=true

* Execute also webpy (default port 8080)

::

  cd ~cuckoo/cuckoo/utils
  python web.py

.. image:: /../screenshots/github%20webpy.png?raw=true

* Execute also django using port 6969

::

  cd ~cuckoo/cuckoo/web
  python manage.py runserver 0.0.0.0:6969

.. image:: /../screenshots/github%20django.png?raw=true

Script features
=================

* Installs by default Cuckoo sandbox with the ALL optional stuff: yara, ssdeep, django ...
* Installs the last versions of ssdeep, yara, pydeep-master & jansson.
* Solves common problems during the installation: ldconfigs, autoreconfs...
* Installs by default virtualbox and *creates the hostonlyif*.
* Creates the *'cuckoo'* user in the system and it is also added this user to *vboxusers* group.
* Enables *mongodb* in *conf/reporting.conf* 
* Creates the *iptables rules* and the ip forward to enable internet in the cuckoo virtual machines

::

    sudo iptables -A FORWARD -o eth0 -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT
    sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    sudo iptables -A POSTROUTING -t nat -j MASQUERADE
    sudo sysctl -w net.ipv4.ip_forward=1

Enables run *tcpdump* from nonroot user

::

    sudo apt-get -y install libcap2-bin
    sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

Fixes the *"TEMPLATE_DIRS setting must be a tuple"* error when running python manage.py from the *DJANGO version >= 1.6*. Replacing in *web/web/settings.py*

::

        TEMPLATE_DIRS = (
            "templates"
        )


becomes

::

        TEMPLATE_DIRS = (
            ("templates"),
        )


Install cuckoo as daemon
==========================

For this, we recommend supervisor usage.

Install supervisor

::

    sudo apt-get install supervisor

Edit */etc/supervisor/conf.d/cuckoo.conf* , like

::

        [program:cuckoo]
        command=python cuckoo.py
        directory=/home/cuckoo
        User=cuckoo

        [program:cuckoo-web]
        command=python web.py
        directory=/home/cuckoo/utils
        user=cuckoo

        [program:cuckoo-api]
        command=python api.py
        directory=/home/cuckoo/utils
        user=cuckoo

Reload supervisor

::

  sudo supervisorctl reload


Extra help
==========

You may want to read:

* Script to create templates to use with VirtualBox to make vm detection harder: `https://github.com/nsmfoo/antivmdetection`
* `Remote <./doc/Remote.rst>`_ - Enabling remote administration of VMS and VBox
* `OVA <./doc/OVA.rst>`_ - Working with OVA images
* `Pafish <./doc/Pafish.rst>`_ Pafish - Checking if your VM is detectable by malware
* `VMcloak <./doc/Vmcloak.rst>`_ VMCloak - Cuckoo windows virtual machines management

TODO
====

* Improve pafish documentation on methods to avoid malware vm detection techniques
* Improve documentation

Contributing
============

This project is licensed as GPL3+ as you can see in "LICENSE" file.
All pull requests are welcome, having in mind that:

- The scripting style must be compliant with the current one
- New features must be in sepparate branches (way better if it's git-flow =) )
- Please, check that it works correctly before submitting a PR.

We'd probably be answering to PRs in a 7-14 day period, please be patient.

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

* Add a password (as root) for the user *'cuckoo'* created by the script::
    passwd cuckoo

* Create the virtual machines `http://docs.cuckoosandbox.org/en/latest/installation/guest/`
  or import virtual machines::
  VBoxManage import virtual_machine.ova

* Add to the virtual machines with HostOnly option using vboxnet0::
  vboxmanage modifyvm “virtual_machine" --hostonlyadapter1 vboxnet0
* Configure cuckoo (`http://docs.cuckoosandbox.org/en/latest/installation/host/configuration/` )

* Execute cuckoo (check the image output)::
  cd cuckoo
  python cuckoo.py
.. image:: https://github.com/buguroo/cuckooautoinstall/blob/images/github%20cuckoo%20working.png

* Execute also webpy (default port 8080)::
  cd cuckoo/utils
  python web.py

.. image:: https://github.com/buguroo/cuckooautoinstall/blob/images/github%20webpy.png

* Execute also django using port 6969::
  cd cuckoo/web
  python manage.py runserver 0.0.0.0:6969

.. image:: https://github.com/buguroo/cuckooautoinstall/blob/images/github%20django.png

Script features
=================

* Installs by default Cuckoo sandbox with the ALL optional stuff: yara, ssdeep, django ...
* Installs the last versions of ssdeep, yara, pydeep-master & jansson.
* Solves common problems during the installation: ldconfigs, autoreconfs...
* Installs by default virtualbox and *creates the hostonlyif*.
* Creates the *iptables rules* and the ip forward to enable internet in the cuckoo virtual machines::
    sudo iptables -A FORWARD -o eth0 -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT
    sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    sudo iptables -A POSTROUTING -t nat -j MASQUERADE
    sudo sysctl -w net.ipv4.ip_forward=1

* Enables run *tcpdump* from nonroot user::
    sudo apt-get -y install libcap2-bin
    sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

*Creates the *'cuckoo'* user in the system and it is also added this user to *vboxusers* group.

* Enables *mongodb* in *conf/reporting.conf* 

* Fixes the *"TEMPLATE_DIRS setting must be a tuple"* error when running python manage.py from the *DJANGO version >= 1.6*. Replacing in *web/web/settings.py*::
        TEMPLATE_DIRS = (
        "templates"
        )
        TEMPLATE_DIRS = (
        ("templates"),
        )

Remote access to Virtual Machines via RDP + Remote control of VirtualBox (Optional)
===================================================================================

Download and install Oracle VM VirtualBox Extension Pack from `https://www.virtualbox.org/wiki/Downloads`

Download the VirtualBox Extension Pack for your Distribution and for your Virtualbox version: *vboxmanage --version*. For example::
    ~# vboxmanage --version
    4.1.18_Debianr78361
    #(found this version in Extension Pack Link for All Platforms, in VirtualBox 4.1.18:  https://www.virtualbox.org/wiki/Download_Old_Builds_4_1)
    wget http://download.virtualbox.org/virtualbox/4.1.18/Oracle_VM_VirtualBox_Extension_Pack-4.1.18-78361.vbox-extpack

Install the Extension Pack with: *VBoxManage extpack install*. For example for my 4.1.18_Debianr78361::
    sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.1.18-78361.vbox-extpack

Create the file /etc/default/virtualbox and add the user. I am using the user 'cuckoo' created by the script, this user must be in vboxusers::
    VBOXWEB_USER=cuckoo

* Download and install *phpVirtualbox*: An open source, AJAX implementation of the VirtualBox user interface written in PHP. 
  As a modern web interface, it allows you to access and control remote VirtualBox instances. 
  phpVirtualBox is designed to allow users to administer VirtualBox in a headless environment 
  - mirroring the VirtualBox GUI through its web interface. 
  http://sourceforge.net/projects/phpvirtualbox/ ::
    sudo apt-get install nginx php5-common php5-mysql php5-fpm php-pear unzip
    sudo /etc/init.d/nginx start

Edit /etc/nginx/sites-available/default::
                server {
                        listen   80; ## listen for ipv4; this line is default and implied
                        listen   [::]:80 default ipv6only=on; ## listen for ipv6
                
                        root /usr/share/nginx/www;
                        index index.php index.html index.htm;
                
                        # Make site accessible from http://localhost/
                        server_name _;
                
                        location / {
                                # First attempt to serve request as file, then
                                # as directory, then fall back to index.html
                                try_files $uri $uri/ /index.html;
                                # Uncomment to enable naxsi on this location
                                # include /etc/nginx/naxsi.rules
                        }
                
                        location /doc/ {
                                alias /usr/share/doc/;
                                autoindex on;
                                allow 127.0.0.1;
                                deny all;
                        }
                
                        # Only for nginx-naxsi : process denied requests
                        #location /RequestDenied {
                                # For example, return an error code
                                #return 418;
                        #}
                
                        #error_page 404 /404.html;
                
                        # redirect server error pages to the static page /50x.html
                        #
                        error_page 500 502 503 504 /50x.html;
                        location = /50x.html {
                                root /usr/share/nginx/www;
                        }
                
                        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
                        #
                        location ~ \.php$ {
                                try_files $uri =404;
                                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                                fastcgi_pass unix:/var/run/php5-fpm.sock;
                                fastcgi_index index.php;
                                include fastcgi_params;
                        }
                
                        # deny access to .htaccess files, if Apache's document root
                        # concurs with nginx's one
                        #
                        location ~ /\.ht {
                                deny all;
                        }
                }
                
Reload nginx config::
    sudo /etc/init.d/nginx reload

Install the last phpVirtualBox and extract it in the nginx web.
phpVirtualBox versioning is aligned with VirtualBox versioning in that the major and minor release numbers will maintain compatibility::
    phpVirtualBox 4.0-x will always be compatible with VirtualBox 4.0.x. 
    Regardless of what the latest x revision is.     
    phpVirtualBox 4.2-x will always be compatible with VirtualBox 4.2.x, etc.. 
    for VirtualBox 4.3 - phpvirtualbox-4.3-x.zip 
    for VirtualBox 4.2 - phpvirtualbox-4.2-x.zip 
    for VirtualBox 4.1 - phpvirtualbox-4.1-x.zip 
    for VirtualBox 4.0 - phpvirtualbox-4.0-x.zip 
    ...

I am using Virtualbox 4.1.18_Debianr78361 and I found a version for my version: phpvirtualbox-4.1-11.zip http://sourceforge.net/projects/phpvirtualbox/files/Older%20versions/

Download and extract the CORRECT phpvirtualbox version for your Virtualbox version in the nginx public web path::
    cd /usr/share/nginx/www
    sudo wget -L -c http://sourceforge.net/projects/phpvirtualbox/files/Older%20versions/phpvirtualbox-4.1-11.zip/download -O phpvirtualbox.zip 
    sudo unzip phpvirtualbox.zip

Copy the config sample like default config::
    cd phpvirtualbox-4.1-11
    sudo cp config.php-example config.php

Edit config.php and add the cuckoo user::
    var $username = 'cuckoo';
    var $password = '12345';

Start vboxweb service using the *same user of the config.php* of the 
phpVirtualbox. In my (old) Virtualbox version you can use this command::
    su cuckoo
    vboxwebsrv -H 127.0.0.1 --background

And for new versions::
    sudo VBoxManage setproperty websrvauthlibrary default
    sudo /etc/init.d/vboxweb-service restart

Access to the phpvirtualbox web, the default password and user for the web is *admin*.

For common issues and problems visit: http://sourceforge.net/p/phpvirtualbox/wiki/Common%20phpVirtualBox%20Errors%20and%20Issues/

* Install a RDP Client to access to virtual machines (you can use the *Windows Remote Desktop client*).

.. image:: https://github.com/buguroo/cuckooautoinstall/blob/images/github%20access.png

Install cuckoo as daemon
==========================

For this, we recommend supervisor usage.

Install supervisor::
    sudo apt-get install supervisor

Edit */etc/supervisor/conf.d/cuckoo.conf* , like::
        [program:cuckoo]
        command=python cuckoo.py
        directory=/home/cuckoo
        User=cuckoo

        [program:cuckoo-web]
        command=python web.py
        directory=/home/cuckoo/utils
        user=cuckoo[program:cuckoo-api]
        command=python api.py
        directory=/home/cuckoo/utils
        user=cuckoo

Reload supervisor::
  sudo supervisorctl reload

Import OVF (.OVA) Virtual Machines
=================
Read first: http://docs.cuckoosandbox.org/en/latest/installation/guest/

Normally I create the Virtual Machine from my Windows and after I export the 
virtual machine using the file menu in Virtual Box. I export the virtual 
machine using the OVF format (.OVA). Then I copy the virtual machine 
to my server using sftp.

You can use the *VBoxManage import* command to import a virtual machine. 
Use the user created for cuckoo. Here an example to import my 
Virtual Machine "windows_7.ova" created from VirtualBox in Windows::
    su cuckoo
    VBoxManage import windows_7.ova

If you are using phpVirtualbox with a old VirtualBox 
version and you are running the command 
/usr/lib/virtualbox/vboxwebsrv -H 127.0.0.1 --background 
execute the command from the same user of the config.php of phpVirtualbox.
Like this::
    su cuckoo
    /usr/lib/virtualbox/vboxwebsrv -H 127.0.0.1 --background

Configure HostOnly adapter to the virtual machine, you can list your virtual
machines with the *VBoxManage list vms* command.
Use the user created for cuckoo. For my Windows_7 virtual machine::
    su cuckoo
    vboxmanage modifyvm "windows_7" --hostonlyadapter1 vboxnet0
    
Start the virtual machine with *vboxmanage startvm* command.
Use the user created for cuckoo. For example::
    su cuckoo
    vboxmanage startvm "windows_7" --type headless

Making the screenshot using the user created for cuckoo. 
For my windows_7 virtual machine I want create a snapshoot called cuckoosnap::

    su cuckoo
    VBoxManage snapshot "windows_7" take "cuckoosnap" --pause
    VBoxManage controlvm "windows_7" poweroff
    VBoxManage snapshot "windows_7" restorecurrent

Add the new virtual machine with the new snapshot and with the static IP
address to the *conf/virtualbox.conf:*::
    mode = headless
    machines = cuckoo1
    [cuckoo1]
    label = windows_7
    platform = Windows
    ip = 192.168.56.130
    snapshot = cuckoosnap
    interface = vboxnet0

Restart cuckoo.

TODO
====
* Add vmcloak info to README: http://vmcloak.org/ Automated Virtual Machine Generation and Cloaking tailored for Cuckoo Sandbox.
* Add Pafish info to README: https://github.com/a0rtega/pafish The objective of this project is to collect usual tricks seen in malware samples. This allows us to study it, and test if our analysis environments are properly implemented.
* Add hardening cuckoo info to README.
* Test the script in more environments
* Add documentation on new configuration system

Pull requests are always welcome
++++++++++++++++++++++++++++++++

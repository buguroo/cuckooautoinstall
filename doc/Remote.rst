Remote access to Virtual Machines via RDP + Remote control of VirtualBox (Optional)
===================================================================================

Download and install Oracle VM VirtualBox Extension Pack from `https://www.virtualbox.org/wiki/Downloads`

Download the VirtualBox Extension Pack for your Distribution and for your Virtualbox version: *vboxmanage --version*. For example

::

    ~# vboxmanage --version
    4.1.18_Debianr78361
    #(found this version in Extension Pack Link for All Platforms, in VirtualBox 4.1.18:  https://www.virtualbox.org/wiki/Download_Old_Builds_4_1)
    wget http://download.virtualbox.org/virtualbox/4.1.18/Oracle_VM_VirtualBox_Extension_Pack-4.1.18-78361.vbox-extpack

Install the Extension Pack with: *VBoxManage extpack install*. For example for my 4.1.18_Debianr78361

::

    sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.1.18-78361.vbox-extpack

Create the file /etc/default/virtualbox and add the user. I am using the user 'cuckoo' created by the script, this user must be in vboxusers

::

    VBOXWEB_USER=cuckoo

Download and install *phpVirtualbox*: An open source, AJAX implementation of
the VirtualBox user interface written in PHP. 
As a modern web interface, it allows you to access and control remote VirtualBox instances. 
phpVirtualBox is designed to allow users to administer VirtualBox in a headless environment 
mirroring the VirtualBox GUI through its web interface. 

http://sourceforge.net/projects/phpvirtualbox/

Install packages

::

    sudo apt-get install nginx php5-common php5-mysql php5-fpm php-pear unzip

Start ngnix

::

    sudo /etc/init.d/nginx start

Enable php in ngnix config.

Reload nginx

::

    sudo /etc/init.d/nginx reload

Install the last phpVirtualBox and extract it in the nginx web.
phpVirtualBox versioning is aligned with VirtualBox versioning in that the major 
and minor release numbers will maintain compatibility

::

    phpVirtualBox 4.0-x will always be compatible with VirtualBox 4.0.x. 
    Regardless of what the latest x revision is.     
    phpVirtualBox 4.2-x will always be compatible with VirtualBox 4.2.x, etc.. 
    for VirtualBox 4.3 - phpvirtualbox-4.3-x.zip 
    for VirtualBox 4.2 - phpvirtualbox-4.2-x.zip 
    for VirtualBox 4.1 - phpvirtualbox-4.1-x.zip 
    for VirtualBox 4.0 - phpvirtualbox-4.0-x.zip 

I am using Virtualbox 4.1.18_Debianr78361 and I found a version for my version: phpvirtualbox-4.1-11.zip http://sourceforge.net/projects/phpvirtualbox/files/Older%20versions/

Download and extract the CORRECT phpvirtualbox version for your Virtualbox version in the nginx public web path

::

    cd /usr/share/nginx/www
    sudo wget -L -c http://sourceforge.net/projects/phpvirtualbox/files/Older%20versions/phpvirtualbox-4.1-11.zip/download -O phpvirtualbox.zip 
    sudo unzip phpvirtualbox.zip

Copy the config sample like default config

::

    cd phpvirtualbox-4.1-11
    sudo cp config.php-example config.php

Edit config.php and add the cuckoo user

::

    var $username = 'cuckoo';
    var $password = '12345';

Start vboxweb service using the *same user of the config.php* of the 
phpVirtualbox. In my (old) Virtualbox version you can use this command

::

    su cuckoo
    vboxwebsrv -H 127.0.0.1 --background

And for new versions

::

    sudo VBoxManage setproperty websrvauthlibrary default
    sudo /etc/init.d/vboxweb-service restart

Access to the phpvirtualbox web, the default password and user for the web is *admin*.

For common issues and problems visit: http://sourceforge.net/p/phpvirtualbox/wiki/Common%20phpVirtualBox%20Errors%20and%20Issues/

Install a RDP Client to access to virtual machines (you can use the *Windows Remote Desktop client*).

.. image:: /../screenshots/github%20access.png?raw=true



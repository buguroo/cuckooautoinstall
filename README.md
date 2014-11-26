cuckooautoinstall
=================
Auto Installer Script for Cuckoo Sandbox: [http://cuckoosandbox.org/](http://cuckoosandbox.org/)

What is Cuckoo Sandbox?

In three words, Cuckoo Sandbox is a malware analysis system.

What does that mean? It simply means that you can throw any suspicious file at it and in a matter of seconds Cuckoo will provide you back some detailed results outlining what such file did when executed inside an isolated environment.

I created this script to avoid waste my time installing Cuckoo Sandbox in Debian Stable. 

Usage
=================
* Execute the script: <strong>sh cuckooautoinstall.sh</strong>
* Create the virtual machines [http://docs.cuckoosandbox.org/en/latest/installation/guest/](http://docs.cuckoosandbox.org/en/latest/installation/guest/)
* webpy: cd cuckoo/utils && python web.py
* (https://github.com/David-Reguera-Garcia-Dreg/cuckooautoinstall/blob/master/github%20webpy.png)
  <li>django: cd cuckoo/web && python manage.py runserver 0.0.0.0:6969
  ![ScreenShot](https://github.com/David-Reguera-Garcia-Dreg/cuckooautoinstall/blob/master/github%20django.png)</li>
  <li></li>

</ol>

Remote access to Virtual Machines via RDP + Remote control of VirtualBox :
* Install Oracle VM VirtualBox Extension Pack: [https://www.virtualbox.org/](https://www.virtualbox.org/)
* Install Install phpVirtualbox: An open source, AJAX implementation of the VirtualBox user interface written in PHP. As a modern web interface, it allows you to access and control remote VirtualBox instances. phpVirtualBox is designed to allow users to administer VirtualBox in a headless environment - mirroring the VirtualBox GUI through its web interface. [http://sourceforge.net/projects/phpvirtualbox/](http://sourceforge.net/projects/phpvirtualbox/)
* Install a RDP Client to access to virtual machines.

![ScreenShot](https://github.com/David-Reguera-Garcia-Dreg/cuckooautoinstall/blob/master/github%20access.png)


Script features
=================
It installs by default cuckoo sandbox with the ALL optional stuff: yara, ssdeep, django ...

It installs the last versions of: ssdeep, yara, pydeep-master & jansson.

It tries to solve common problems during the installation: ldconfigs, autoreconfs...

It installs by default virtualbox and creates the hostonlyif.

It creates the iptables rules and the ip forward to enable internet in the cuckoo virtual machines:

    sudo iptables -A FORWARD -o eth0 -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT
    
    sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    
    sudo iptables -A POSTROUTING -t nat -j MASQUERADE
    
    sudo sysctl -w net.ipv4.ip_forward=1
    
It enables run tcpdump from nonroot user:

    sudo apt-get -y install libcap2-bin
    
    sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

It creates the cuckoo user in the system (it is also added to vboxusers group).

It enables mongodb in conf/reporting.conf 

It fix the "TEMPLATE_DIRS setting must be a tuple" error when running python manage.py from the DJANGO version >= 1.6. Replacing at web/web/settings.py:

        TEMPLATE_DIRS = (
        "templates"
        )
    with:
        TEMPLATE_DIRS = (
        ("templates"),
        )


TODO
=================
Add support for more Linux Distributions.

Improve the script (sorry for my bad Bash skills).

Add args to enable and disable functions like: no install django, no enable mongodb, select virtualbox/kvm installation, apply only a workarround patch (like the django patch) etc.

Test the script in more environments

...

Pull requests are always well come :D

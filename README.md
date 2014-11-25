cuckooautoinstall
=================
Auto Installer Script for Cuckoo Sandbox: http://cuckoosandbox.org/
What is Cuckoo Sandbox?

In three words, Cuckoo Sandbox is a malware analysis system.

What does that mean? It simply means that you can throw any suspicious file at it and in a matter of seconds Cuckoo will provide you back some detailed results outlining what such file did when executed inside an isolated environment.

I created this script to avoid waste my time installing Cuckoo Sandbox in Debian Stable. 

Use
=================
....

Script features
=================
It installs by default cuckoo sandbox with the ALL optional stuff: yara, ssdeep, django ...

It uses the last version of: ssdeep, yara, pydeep-master & jansson.

It try to solve common problems during the installation: ldconfigs, autoreconfs...

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

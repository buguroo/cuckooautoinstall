cuckooautoinstall
=================
Auto Installer Script for Cuckoo Sandbox: [http://cuckoosandbox.org/](http://cuckoosandbox.org/)

What is Cuckoo Sandbox?

In three words, Cuckoo Sandbox is a malware analysis system.

What does that mean? It simply means that you can throw any suspicious file at it and in a matter of seconds Cuckoo will provide you back some detailed results outlining what such file did when executed inside an isolated environment.

I created this script in [Buguroo Offensive Security](https://buguroo.com/) to avoid wasting my time installing Cuckoo Sandbox in <strong>Debian Stable</strong>. 

Usage
=================
* Execute the script: <strong>sh cuckooautoinstall.sh</strong>
* Create the virtual machines [http://docs.cuckoosandbox.org/en/latest/installation/guest/](http://docs.cuckoosandbox.org/en/latest/installation/guest/) or import virtual machines using <strong>VBoxManage import virtual_machine.ova</strong>
* Add to the virtual machines with HostOnly option using vboxnet0: <strong>vboxmanage modifyvm “virtual_machine" --hostonlyadapter1 vboxnet0</strong> (use this command to list the VMs: <strong>VBoxManage list vms</strong>)
* Configure cuckoo: <strong>[cuckoo/conf/cuckoo.conf](http://docs.cuckoosandbox.org/en/latest/installation/host/configuration/#cuckoo-conf), [cuckoo/conf/auxiliary.conf](http://docs.cuckoosandbox.org/en/latest/installation/host/configuration/#auxiliary-conf) & [cuckoo/conf/virtualbox.conf](http://docs.cuckoosandbox.org/en/latest/installation/host/configuration/#machinery-conf)</strong> 
* Execute cuckoo (check the image output): <strong>cd cuckoo && python cuckoo.py</strong>

![ScreenShot](https://github.com/buguroo/cuckooautoinstall/blob/master/github%20cuckoo%20working.png)
* Execute also webpy: <strong>cd cuckoo/utils && python web.py</strong>

![ScreenShot](https://github.com/buguroo/cuckooautoinstall/blob/master/github%20webpy.png)
* Execute also django: <strong>cd cuckoo/web && python manage.py runserver 0.0.0.0:6969</strong>

![ScreenShot](https://github.com/buguroo/cuckooautoinstall/blob/master/github%20django.png)

Remote access to Virtual Machines via RDP + Remote control of VirtualBox
=================
* Download and install <strong>Oracle VM VirtualBox Extension Pack</strong>: [https://www.virtualbox.org/wiki/Downloads  ](https://www.virtualbox.org/wiki/Downloads  ):

Download the VirtualBox Extension Pack for your Distribution and for your Virtualbox version: <strong>vboxmanage --version</strong>. For example:

    root@cuckoolab3:~# vboxmanage --version
    4.1.18_Debianr78361
    #(found this version in Extension Pack Link for All Platforms, in VirtualBox 4.1.18:  https://www.virtualbox.org/wiki/Download_Old_Builds_4_1)
    wget http://download.virtualbox.org/virtualbox/4.1.18/Oracle_VM_VirtualBox_Extension_Pack-4.1.18-78361.vbox-extpack

Install the Extension Pack with: <strong>VBoxManage extpack install</strong>. For example for my 4.1.18_Debianr78361: 

    VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.1.18-78361.vbox-extpack
                
Create the file /etc/default/virtualbox and add the user. I am using the user 'cuckoo' created by the script, this user must be in vboxusers: 

    VBOXWEB_USER=cuckoo

* Download and install <strong>phpVirtualbox</strong>: An open source, AJAX implementation of the VirtualBox user interface written in PHP. As a modern web interface, it allows you to access and control remote VirtualBox instances. phpVirtualBox is designed to allow users to administer VirtualBox in a headless environment - mirroring the VirtualBox GUI through its web interface. [http://sourceforge.net/projects/phpvirtualbox/](http://sourceforge.net/projects/phpvirtualbox/)

Install dependences:

    apt-get install nginx php5-common php5-mysql php5-fpm php-pear unzip
                
Start nginx:

    /etc/init.d/nginx start
                
Edit /etc/nginx/sites-available/default:

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
                
Reload nginx config:

    /etc/init.d/nginx reload

Install the last phpVirtualBox and extract it in the nginx web.

phpVirtualBox versioning is aligned with VirtualBox versioning in that the major and minor release numbers will maintain compatibility. 

    phpVirtualBox 4.0-x will always be compatible with VirtualBox 4.0.x. Regardless of what the latest x revision is.     phpVirtualBox 4.2-x will always be compatible with VirtualBox 4.2.x, etc.. *) 
    for VirtualBox 4.3 - phpvirtualbox-4.3-x.zip *) 
    for VirtualBox 4.2 - phpvirtualbox-4.2-x.zip *)
    for VirtualBox 4.1 - phpvirtualbox-4.1-x.zip *)
    for VirtualBox 4.0 - phpvirtualbox-4.0-x.zip *) 
    ...

I am using Virtualbox 4.1.18_Debianr78361 and I found a version for this in: [http://sourceforge.net/projects/phpvirtualbox/files/Older%20versions/](http://sourceforge.net/projects/phpvirtualbox/files/Older%20versions/) phpvirtualbox-4.1-11.zip

Download and extract the CORRECT phpvirtualbox version in the nginx public web path:

    cd /usr/share/nginx/www
    wget -L -c http://sourceforge.net/projects/phpvirtualbox/files/Older%20versions/phpvirtualbox-4.1-11.zip/download -O phpvirtualbox.zip 
    unzip phpvirtualbox.zip

Copy the config sample like default config:

    cp config.php-example config.php

Edit config.php and add the cuckoo user:

    var $username = 'cuckoo';
    var $password = '12345';

Start  vboxweb service, in my Virtualbox version (is old) you can use this command:

     vboxwebsrv -H 127.0.0.1

And for new versions:
 
    VBoxManage setproperty websrvauthlibrary default
    /etc/init.d/vboxweb-service restart

Access to the phpvirtualbox web, the default password and user for the web is <strong>admin</strong>.

* Install a RDP Client to access to virtual machines (you can use the <strong>Windows Remote Desktop client</strong>).

![ScreenShot](https://github.com/buguroo/cuckooautoinstall/blob/master/github%20access.png)

Install <strong>cuckoo as daemon</strong>:

* <strong>apt-get install supervisor</strong>
* Edit <strong>/etc/supervisor/conf.d/cuckoo.conf</strong> example:

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

* Reload supervisor: supervisorctl reload

Script features
=================
It installs by default Cuckoo sandbox with the ALL optional stuff: yara, ssdeep, django ...

It installs the last versions of: ssdeep, yara, pydeep-master & jansson.

It tries to solve common problems during the installation: ldconfigs, autoreconfs...

It installs by default virtualbox and <strong>creates the hostonlyif</strong>.

It creates the <strong>iptables rules</strong> and the ip forward to enable internet in the cuckoo virtual machines:

    sudo iptables -A FORWARD -o eth0 -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT
    sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    sudo iptables -A POSTROUTING -t nat -j MASQUERADE
    sudo sysctl -w net.ipv4.ip_forward=1

It enables run <strong>tcpdump</strong> from nonroot user:

    sudo apt-get -y install libcap2-bin
    sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

It creates the <strong>'cuckoo'</strong> user in the system and it is also added this user to <strong>vboxusers</strong> group.

It enables <strong>mongodb</strong> in <strong>conf/reporting.conf</strong> 

It fix the <strong>"TEMPLATE_DIRS setting must be a tuple"</strong> error when running python manage.py from the <strong>DJANGO version >= 1.6</strong>. Replacing in <strong>web/web/settings.py</strong>:

        TEMPLATE_DIRS = (
        "templates"
        )
    For:
        TEMPLATE_DIRS = (
        ("templates"),
        )

TO-DO
=================
* Add support for more Linux Distributions.
* Improve the script (sorry for my bad Bash skills).
* Add arguments to the script in order to enable and disable things like: do not install django, do not enable mongodb, install phpvirtualbox, select virtualbox, vmware or kvm installation, apply or do not apply a workarround patch (ex: django patch) etc.
* Test the script in more environments
* ...

##<strong>Pull requests are always welcome :D</strong>

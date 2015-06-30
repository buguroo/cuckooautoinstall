Import OVF (.OVA) Virtual Machines
==================================
Read first: http://docs.cuckoosandbox.org/en/latest/installation/guest/

Normally I create the Virtual Machine from my Windows and after I export the 
virtual machine using the file menu in Virtual Box. I export the virtual 
machine using the OVF format (.OVA). Then I copy the virtual machine 
to my server using sftp.

You can use the *VBoxManage import* command to import a virtual machine. 
Use the user created for cuckoo. Here an example to import my 
Virtual Machine "windows_7.ova" created from VirtualBox in Windows

::

    su cuckoo
    VBoxManage import windows_7.ova

If you are using phpVirtualbox with a old VirtualBox 
version and you are running the command 
/usr/lib/virtualbox/vboxwebsrv -H 127.0.0.1 --background 
execute the command from the same user of the config.php of phpVirtualbox.
Like this

::

    su cuckoo
    /usr/lib/virtualbox/vboxwebsrv -H 127.0.0.1 --background

Configure HostOnly adapter to the virtual machine, you can list your virtual
machines with the *VBoxManage list vms* command.
Use the user created for cuckoo. For my Windows_7 virtual machine

::

    su cuckoo
    vboxmanage modifyvm "windows_7" --hostonlyadapter1 vboxnet0
    
Start the virtual machine with *vboxmanage startvm* command.
Use the user created for cuckoo. For example

::

    su cuckoo
    vboxmanage startvm "windows_7" --type headless

Making the screenshot using the user created for cuckoo. 
For my windows_7 virtual machine I want create a snapshoot called cuckoosnap

::

    su cuckoo
    VBoxManage snapshot "windows_7" take "cuckoosnap" --pause
    VBoxManage controlvm "windows_7" poweroff
    VBoxManage snapshot "windows_7" restorecurrent

Add the new virtual machine with the new snapshot and with the static IP
address to the *conf/virtualbox.conf:*

::

    mode = headless
    machines = cuckoo1
    [cuckoo1]
    label = windows_7
    platform = Windows
    ip = 192.168.56.130
    snapshot = cuckoosnap
    interface = vboxnet0

Restart cuckoo.



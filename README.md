MineCraftEC2init

initial setup script for minecraft with MSM (https://github.com/marcuswhybrow/minecraft-server-manager)
on an AWS EC2 instance

this script is meant to be linked in the user-data when creating a new EC2 instance
```
#!/bin/bash
wget -q https://raw.github.com/zachofalltrades/MineCraftEC2init/master/setup-redhat.sh -O /tmp/msminstall.sh
source /tmp/msminstall.sh
```

You should be able to log into your new instance and have an up to date MSM environment ready to go. You will probably want to check the configuration (especially backup options and RAM).
```
sudo nano /etc/msm.conf
```

Now you are off and running with MSM!
```
sudo msm help
```


This init script loads a helper library for the No-IP service, so that you can reach your server with a domain name. To configure this service (completely optional), you will have to issue the following commands after logging in via SSH. 
```
sudo noip2 -C
sudo chkconfig noip on
sudo service noip start
```
You will be prompeted for your username and password for the No-IP dynamic DNS service. The utility will immediately login to the given account and prompt you to select which host(s) you want to associate with this update client. The configuration file that this utility saves IS encrypted, but I can not vouch for it. 

 

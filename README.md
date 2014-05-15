MineCraftEC2init
================

initial setup script for minecraft with MSM (https://github.com/marcuswhybrow/minecraft-server-manager)
on an AWS EC2 instance

this script is meant to be linked in the user-data when creating a new EC2 instance

#include https://raw.github.com/zachofalltrades/MineCraftEC2init/master/setup-redhat.sh



post-install, login via shell and go through interactive setup:
-----------------
sudo noip2 -C
-->login/email
-->password
configure all hosts? N...N...Y...
-->update interval
-->run something after successful update? N...
New configuration file '/etc/no-ip2.conf' created. [encrypted]

sudo chkconfig noip on
sudo service noip start

 
check configuration (especially backup options and RAM)
-----------------
sudo nano /etc/msm.conf

sudo msm help

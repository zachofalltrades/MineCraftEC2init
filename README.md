MineCraftEC2init
================

initial setup script for minecraft with MSM on an AWS EC2 instance

this script can be linked in the user-data when creating a new EC2 instance
https://raw.github.com/zachofalltrades/MineCraftEC2init/master/setup-redhat.sh



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

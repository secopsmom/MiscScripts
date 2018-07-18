#!/bin/sh
# This is a script to update and install needed packages for CentOS/RHEL based-servers

function yum_update_run {
	echo 'Forcing full YUM update.  This may take some time...'
	yum clean all >> /var/log/initial_setup.log 2>&1
	yum update -y >> /var/log/initial_setup.log 2>&1
}

function yum_repos {
	echo 'Configuring YUM to use local CentOS Repos...'
	yum install wget -y >> /var/log/initial_setup.log 2>&1
}

function install_basics {
	echo 'Installing some basic packages...'
	# yum install desired rpms for simple packages 
	yum install man perl ntp net-snmp screen nmap audit eject tcpdump vim-enhanced openssh-clients openssh-server traceroute mtr sudo mlocate rsync psacct -y >> /var/log/initial_setup.log 2>&1
}

function config_vim {
	echo 'Configuring vim-enhanced...'
	echo 'Setting desert vim color scheme...'
	echo 'colorscheme desert' >> /etc/vimrc
	echo 'Setting vi alias...'
	echo 'alias vi=vim' >> /etc/bashrc
}

function set_selinux_permissive {
	echo 'Setting SELINUX to permissive mode...'
	sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
	setenforce 0 >> /var/log/initial_setup.log 2>&1
}

function remove_crapware {
	echo 'Removing unnecessary packages...'
	# Any of the packages below can be modified to suit your needs
	yum -y remove squid exim sendmail krb5-workstation cups at isdn4k-utils sendmail irda-utils mt-st samba-common sendmail-cf talk up2date ypbind yp-tools wvdial lockdev procmail xorg-x11-font-utils pam_ccreds gdm bluez-utils yum-updatesd libX11  >> /var/log/initial_setup.log 2>&1
	echo 'Disabling unnecessary services...'
		for d in rpcidmapd rpcgssd firstboot nfslock netfs portmap avahi-daemon avahi-dnsconfd pcscd bluetooth gpm autofs mcstrans messagebus restorecond haldaemon iptables ip6tables kudzu netfs nfs rawdevices; do
			    chkconfig --level 0123456 $d off >> /var/log/initial_setup.log 2>&1
			    service $d stop >> /var/log/initial_setup.log 2>&1
		done 
}

function create_users {
echo 'Creating user account(s)'
# USERNAME - replace with real username
adduser USERNAME
echo "ChangeMe1234" | passwd --stdin USERNAME >> /var/log/initial_setup.log 2>&1
usermod -a -G wheel USERNAME
mkdir /home/USERNAME/.ssh
touch /home/USERNAME/.ssh/authorized_keys
chown -R USERNAME:USERNAME /home/USERNAME/.ssh/
chmod 700 /home/USERNAME/.ssh/
chmod 600 /home/USERNAME/.ssh/authorized_keys
#
#<<<<KEY INFO HERE>>> should contain user key
#
echo "ssh-rsa  USERNAME <<KEY INFO HERE>>>" > /home/USERNAME/.ssh/authorized_keys
# End of user accounts
fi
echo 'User Accounts Created...'
}

function setup_server {
 yum_repos
 yum_update_run
 install_basics
 config_vim
 remove_crapware
 set_selinux_permissive
 create_users
 
 echo ‘All Done!  A log file has been generated at /var/log/initial_setup.log'
 echo 'Time for a reboot...'
 
 OPTIONS="RebootNow! GETOut!"
select opt in $OPTIONS; do
   if [ "$opt" = "RebootNow!" ]; then
      reboot
      exit
   else
      echo 'Bye now!'
      exit
   fi
done
}

clear
echo 'Server Setup Script'
echo '==========================='
echo 'Run this on a fresh CentOS/RHEL box'
echo 'Select “YES” to proceed.'
OPTIONS="Understood NOT SURE"
select opt in $OPTIONS; do
   if [ "$opt" = “YES” ]; then
      setup_server
      exit
   else
      echo 'Buh-bye now!'
      exit
   fi
done

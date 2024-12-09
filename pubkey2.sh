#!/bin/bash

if [ -z "$3" ]
then
	echo "Usage: `basename $0` <public.pem> <username> <IP/hostname>"
	echo "Examp: `basename $0` public-PavelKrejci-20240326.pem pkrejci 192.168.8.128"
	exit 1
fi

#first delete known_hosts record to avoid failure
sed -i "/^$3/d" ~/.ssh/known_hosts
#sed -i "/^$3/d" /home/admin/.ssh/known_hosts

cat $1 | ssh -o "StrictHostKeyChecking no" $2@$3 "mkdir .ssh; chmod 700 .ssh; echo >>.ssh/authorized_keys; chmod 600 .ssh/authorized_keys; cat - >> .ssh/authorized_keys"

scp ~/bin/rc/vimrc $2@$3:.vimrc
scp ~/bin/rc/screenrc $2@$3:.screenrc
#scp ~/bin/findgrep $2@$3:
scp ~/bin/rc/bash_aliases $2@$3:.bash_aliases

ssh $2@$3 "cp ~/.bashrc ~/.bashrc.$(date +%Y%m%d%H%M%S)"
if [ "$2" == "root" ]; then
	scp ~/bin/rc/bashrc.root $2@$3:.bashrc
else
	scp ~/bin/rc/bashrc $2@$3:.bashrc
fi

#ssh engr@$1 "/usr/bin/sed -i '/^TMOUT/d' /etc/profile"

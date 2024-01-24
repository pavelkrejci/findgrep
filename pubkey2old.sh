#!/bin/bash

if [ -z "$1" ]
then
	echo "Usage:" `basename $0` "10.6.43.5"
	exit 1
fi

#first delete known_hosts record to avoid failure
sed -i "/^$1/d" ~/.ssh/known_hosts
sed -i "/^$1/d" /home/admin/.ssh/known_hosts

cat /cygdrive/c/Users/admin/Documents/_SSHkeys/public.pub | ssh -o "StrictHostKeyChecking no" engr@$1 "mkdir /home/engr/.ssh; chown engr:service /home/engr/.ssh; chmod 700 /home/engr/.ssh; echo >>/home/engr/.ssh/authorized_keys; chmod 600 /home/engr/.ssh/authorized_keys; chown engr:service /home/engr/.ssh/authorized_keys; cat - >> /home/engr/.ssh/authorized_keys"

scp ~/bin/vim-data-7.2-8.20.8.i586.rpm ~/bin/vim-data-7.2-8.21.3.1.x86_64.rpm engr@$1:
ssh engr@$1 "rpm -Uvh vim-data-7.2-8.20.8.i586.rpm"
ssh engr@$1 "rpm -Uvh vim-data-7.2-8.21.3.1.x86_64.rpm"

scp ~/bin/vimrc engr@$1:/root/.vimrc
scp ~/bin/screenrc engr@$1:/root/.screenrc
scp ~/bin/findgrep engr@$1:/root/bin/

ssh engr@$1 "/usr/bin/sed -i '/^TMOUT/d' /etc/profile"


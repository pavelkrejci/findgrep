#!/bin/bash

if [ -z "$1" ]
then
	echo "Usage:" `basename $0` "10.100.82.110"
	exit 1
fi

#first delete known_hosts record to avoid failure
sed -i "/^$1/d" ~/.ssh/known_hosts
sed -i "/^$1/d" /home/admin/.ssh/known_hosts

cat  /cygdrive/c/Users/admin/Documents/_SSHkeys/public.pub | ssh -o "StrictHostKeyChecking no" root@$1 "mkdir /root/.ssh; chown root:root /root/.ssh; echo >>/root/.ssh/authorized_keys; cat - >> /root/.ssh/authorized_keys"

scp ~/bin/vimrc root@$1:/root/.vimrc
scp ~/bin/findgrep root@$1:/root/bin/

ssh root@$1 "/usr/bin/sed -i '/^TMOUT/d' /etc/profile"

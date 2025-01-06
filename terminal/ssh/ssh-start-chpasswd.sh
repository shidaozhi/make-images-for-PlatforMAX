#! /bin/bash
echo "NEW PASSWORD is $PASSWORD"
echo "root:$PASSWORD" | chpasswd
if test $? -eq "0"
then 
  /usr/sbin/sshd -D
else
  echo "Failed to change passwd for root"
  exit 1
fi

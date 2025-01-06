#!/bin/sh

chmod 777 /usr/sbin/ssh-start-chpasswd.sh
jupyter server -y --generate-config || jupyter notebook --generate-config
mkdir -p /root/.jupyter/custom


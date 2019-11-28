#!/bin/bash

useradd anna
useradd marc

echo 'anna' | passwd anna --stdin
echo 'marc' | passwd marc --stdin



cp /opt/docker/login.defs /etc/login.defs
cp /opt/docker/system-auth /etc/pam.d/system-auth

tar xvzf ./pam-python-1.0.7.tar.gz

dnf -y install sphinx python3-sphinx python2-sphinx gcc
dnf -y install pam-devel
dnf -y install redhat-rpm-config
dnf -y install python-devel


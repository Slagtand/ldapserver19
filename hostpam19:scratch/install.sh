#!/bin/bash

useradd local1
useradd local2
useradd local3

echo 'local1' | passwd local1 --stdin
echo 'local2' | passwd local2 --stdin
echo 'local3' | passwd local3 --stdin

cp /opt/docker/nslcd.conf /etc/nslcd.conf
cp /opt/docker/nsswitch.conf /etc/nsswitch.conf

authconfig --enableshadow --enablelocauthorize \
            --enableldap --enableldapauth \
            --ldapserver='ldapserver' --ldapbase='dc=edt,dc=org' \
            --enablemkhomedir --updateall
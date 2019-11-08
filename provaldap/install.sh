#!/bin/bash
# install ldapserver

rm -rf /etc/openldap/slapd.d/*
rm -rf /var/lib/ldap/* 

mkdir /var/lib/ldap.marc.cat
cp /opt/docker/DB_CONFIG /var/lib/ldap.marc.cat

slaptest -f /opt/docker/slapd.conf -F /etc/openldap/slapd.d/  

slapadd -b 'dc=marc,dc=cat' -F /etc/openldap/slapd.d -l /opt/docker/marc.cat.ldif

chown -R ldap:ldap /etc/openldap/slapd.d/
chown -R ldap:ldap /var/lib/ldap/
chown -R ldap:ldap /var/lib/ldap.marc.cat   

cp /opt/docker/ldap.conf /etc/openldap/.


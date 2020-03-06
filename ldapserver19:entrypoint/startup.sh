#!/bin/bash

cp /opt/docker/ldap.conf /etc/openldap/.

case $1 in
    "initdb")
        # Inicialitzem la base de dades sense dades
        rm -rf /etc/openldap/slapd.d/*
        rm -rf /var/lib/ldap/*
        cp /opt/docker/DB_CONFIG /var/lib/ldap/
        slaptest -f /opt/docker/slapd.conf -F /etc/openldap/slapd.d/  
        chown -R ldap:ldap /etc/openldap/slapd.d/
        chown -R ldap:ldap /var/lib/ldap/ 
        # Engegem el servei
        ulimit -n 1024
        /sbin/slapd -d0
        ;;
    "initdbedt")
        # Inicialitzem la base de dades amb dades
        rm -rf /etc/openldap/slapd.d/*
        rm -rf /var/lib/ldap/*
        cp /opt/docker/DB_CONFIG /var/lib/ldap/
        slaptest -f /opt/docker/slapd.conf -F /etc/openldap/slapd.d/  
        slapadd -F /etc/openldap/slapd.d -l /opt/docker/edt.org.ldif
        chown -R ldap:ldap /etc/openldap/slapd.d/
        chown -R ldap:ldap /var/lib/ldap/ 
        # Engegem el servei
        ulimit -n 1024
        /sbin/slapd -d0
        ;;
    "listdn")
        # Llistem els dn de la base de dades
        slapcat | grep dn
        ;;
    "start" | "")
        # Engegem el servei
        ulimit -n 1024
        /sbin/slapd -d0
        ;;
    *)
        eval "$@"
        ;;
esac



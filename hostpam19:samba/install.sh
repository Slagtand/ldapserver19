#! /bin/bash
# @edt ASIX M06 2019-2020
# instal.lacio
# -------------------------------------
# Creació usuaris locals
bash /opt/docker/localusers.sh

# Configuració client autenticació ldap
bash /opt/docker/auth.sh

# Configuració PAM (mòdul mount)
cp /opt/docker/system-auth /etc/pam.d/system-auth
cp /opt/docker/pam_mount.conf.xml /etc/security/pam_mount.conf.xml
#cp /opt/docker/nslcd.conf /etc/nslcd.conf
#cp /opt/docker/nsswitch.conf /etc/nsswitch.conf
#! /bin/bash
# @edt ASIX M06 2019-2020
# instal.lacio
# -------------------------------------
# Creació usuaris
for user in local1 local2 local3
do
    useradd $user
    echo -e "$user" | passwd --stdin $user
done

for user in lila patipla roc pla
do
    useradd $user
    echo -e "$user\n$user" | smbpasswd -a $user
done

# Configuració client autenticació ldap
bash /opt/docker/auth.sh

# Configuració shares samba
mkdir /var/lib/samba/public
chmod 777 /var/lib/samba/public
cp /opt/docker/* /var/lib/samba/public/.
mkdir /var/lib/samba/privat
#chmod 777 /var/lib/samba/privat
cp /opt/docker/*.md /var/lib/samba/privat/.
cp /opt/docker/smb.conf /etc/samba/smb.conf

# Creació comptes samba i directoris dels usuaris ldap
bash /opt/docker/ldapusers.sh
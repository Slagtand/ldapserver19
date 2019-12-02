#! /bin/bash
# @edt ASIX M06 2019-2020
# instal.lacio
# -------------------------------------
mkdir /var/lib/samba/public
chmod 777 /var/lib/samba/public
cp /opt/docker/* /var/lib/samba/public/.

mkdir /var/lib/samba/privat
#chmod 777 /var/lib/samba/privat
cp /opt/docker/*.md /var/lib/samba/privat/.

cp /opt/docker/smb.conf /etc/samba/smb.conf

for user in local01 local02 local03
do
    useradd $user
    echo -e "$user\n$user" | passwd $user
done

for user in lila patipla roc pla
do
    useradd $user
    echo -e "$user\n$user" | smbpasswd -a $user
done

# useradd lila
# useradd patipla
# useradd roc
# useradd pla

# echo -e "lila\nlila" | smbpasswd -a lila
# echo -e "patipla\npatipla" | smbpasswd -a patipla
# echo -e "roc\nroc" | smbpasswd -a roc
# echo -e "pla\npla" | smbpasswd -a pla
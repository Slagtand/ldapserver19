# SAMBA19:PAM

## Explicació

El que volem aconseguir amb aquesta pràctica és tindre tres contàiners (*ldapserver, samba i pam*) a la mateixa xarxa (*ldapnet*) i que, junt amb el volum *homes*, monti els homes dels usuaris ldap a pam.

## Instal·lació

* Ja que volem fer servir un volum de docker primer l'hauriem de crear (si no està creat).

```bash
docker volume create homes
```

* També hem de ficar els containers a la mateixa xarxa per a que es reconeguin. La creem si no està creada ja.

```bash
docker network create ldapnet
```

### Creació des de 0

* Instal·lem els paquets necessaris:
  
  ```bash
  dnf -y install vim procps samba samba-client cifs-utils authconfig nss-pam-ldapd passwd
  ```

* Configurem els fitxers necessaris directament amb authconfig:
  
  ```bash
  authconfig --enableshadow --enablelocauthorize \
   --enableldap \
   --enableldapauth \
   --ldapserver='ldapserver' \
   --ldapbase='dc=edt,dc=org' \
   --enablemkhomedir \
   --updateall
  ```

* Engegem els serveis:
  
  ```bash
  /sbin/nscd
  /sbin/nslcd
  # Comprovem amb getent que està contactant amb el server ldap
  getent passwd
  # Si ens retorna els usuaris ldap funciona correctament. Si no hauriem de mirar que el servidor ldap funcionés bé, o que estigués engegat.
  ```

* Ara el que toca és, per a cada user de ldap, crear el seu home si no el tenen. Agafarem els usuaris i extraurem les seves dades:
  
  ```bash
  for num in {01..08}
  do
      # Afegim els usuaris per a que siguin users samba
      echo -e "jupiter\njupiter" | smbpasswd -a user$num
      line=$(getent passwd user$num)
      uid=$(echo $line | cut -d ":" -f 3)
      gid=$(echo $line | cut -d ":" -f 4)
      homedir=$(echo $line | cut -d ":" -f 6)
      # Comprovem si el home existeix, si no el crea
      if [ ! -d $homedir ]; then
          mkdir -p $homedir
          cp -ra /etc/skel/* $homedir/.
          # Canviem els permisos del directori al de l'user:grup,         perque si no serien els de root
          chown $uid:$gid $homedir
      fi
  done
  ```

* Copiem la següent configuració de samba per a poguer tindre els homes dels user accessibles. El samba sap quin és el home del user perque quan intenta accedir fa un *getent* de l'usuari
  
  ```bash
  cp /opt/docker/smb.conf /etc/samba/smb.conf
  # Contingut smb.conf
  [global]
          workgroup = MYGROUP
          server string = Samba Server Version %v
          log file = /var/log/samba/log.%m
          max log size = 50
          security = user
          passdb backend = tdbsam
          load printers = yes
          cups options = raw
  [homes]
          comment = Home Directories
          browseable = no
          writable = yes
  ;       valid users = %S
  ;       valid users = MYDOMAIN\%S
  [printers]
          comment = All Printers
          path = /var/spool/samba
          browseable = no
          guest ok = no
          writable = no
          printable = yes
  [documentation]
          comment = Documentació doc del container
          path = /usr/share/doc
          public = yes
          browseable = yes
          writable = no
          printable = no
          guest ok = yes
  [manpages]
          comment = Documentació man  del container
          path = /usr/share/man
          public = yes
          browseable = yes
          writable = no
          printable = no
          guest ok = yes
  [public]
          comment = Share de contingut public
          path = /var/lib/samba/public
          public = yes
          browseable = yes
          writable = yes
          printable = no
          guest ok = yes
  [privat]
          comment = Share d'accés privat
          path = /var/lib/samba/privat
          public = no
          browseable = no
          writable = yes
          printable = no
          guest ok = yes
  ```

* Engegem el servei de samba
  
  ```bash
  /sbin/nmbd
  /sbin/smbd
  ```

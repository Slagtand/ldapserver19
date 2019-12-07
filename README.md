# ldapserver19

## @slagtand Marc Gómez ASIX M06-ASO Curs 2019-2020

## LDAPSERVER

* **ldapserver19:base** servidor ldap bàsic

* **ldapserver19:multi** servidor amb dues bases de dades, dc=edt,dc=org i dc=m06,dc=cat

* **ldapserver19:acl** servidor amb fitxer de configuració de permisos acl

* **ldapserver19:schema** servidor amb diferents esquemes personalitzats.

* **ldapserver19:grups** servidor amb nous grups d'usuaris asix(n)

## HOSTPAM

* **hostpam19:base** servidor base de hostpam. Al iniciar sessió amb un usuari crearem un directori temporal (tmpfs).
  
  ```bash
  # Hem d'arrencar aquest contàiner amb l'opció --privileged, aixi podrà montar els volums.
  docker run --name pam -h pam --net ldapnet --privileged -it marcgc/hostpam19:base /bin/bash
  ```

* Requisits:
  
  * Instal·lar els paquets `pam_mount` i `nfs-utils`
  * Afegir les línies a `/etc/pam.d/system-auth`:
    
    ```bash
    auth        optional      pam_mount.so
    session     required      pam_mkhomedir.so
    session     required      pam_unix.so
    session     optional      pam_mount.so
    ```
  * Afegir les línies següents a `/etc/security/pam_mount.conf.xml`:
    
    ```bash
    <!-- Volume definitions -->
          
                  <volume user="*" fstype="tmpfs" mountpoint="~/tmp" options="size=100M,uid=%(USER),mode=0775" />
          
                <!--  <volume user="*" fstype="nfs" server="172.17.0.1" path="/usr/share/man"  mountpoint="~/%(USER)/man" />  -->
    ```

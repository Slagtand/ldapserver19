# ldapserver19

## @slagtand Marc Gómez ASIX M06-ASO Curs 2019-2020

Repo per a m06 19-20 de ldapserver

## LDAPSERVER

* **ldapserver19:base** servidor ldap bàsic

* **ldapserver19:multi** servidor amb dues bases de dades, dc=edt,dc=org i dc=m06,dc=cat

* **ldapserver19:acl** servidor amb fitxer de configuració de permisos acl

* **ldapserver19:schema** servidor amb diferents esquemes personalitzats.

## HOSTPAM

* **hostpam19:base** servidor base de hostpam. Al iniciar sessió amb un usuari crearem un directori temporal (tmpfs).
  
  ```bash
  # Hem d'arrencar aquest contàiner amb l'opció --privileged, aixi podrà montar els volums.
  docker run --name pam -h pam --net ldapnet --privileged -it marcgc/hostpam19:base /bin/bash
  ```
  
  * Requisits:
    
    * Instal·lar els paquets `pam_mount` i `nfs-utils`
    
    * Afegir les línies a `system-auth`:
      
      ```bash
      auth        optional      pam_mount.so
      session     required      pam_mkhomedir.so
      session     required      pam_unix.so
      session     optional      pam_mount.so    
      ```
    
    * Afegir les línies següents a `pam_mount.conf.xml`:
      
      ```bash
      <!-- Volume definitions -->
       
      		<volume user="*" fstype="tmpfs" mountpoint="~/tmp" options="size=100M,uid=%(USER),mode=0775" />
      
      		<volume user="*" fstype="nfs" server="172.17.0.1" path="/usr/share/man"  mountpoint="~/%(USER)/man" />
      ```

* **hostpam19:auth** contàiner que autentifica tant usuaris locals com d'un servidor ldap i monta els directoris com **base**
  
  ```bash
  # Executem els dos contàiners i els fiquem a una network que haguem creat
  docker run --name ldapserver -h ldapserver --net ldapnet -d marcgc/ldapserver19
  docker run --name pam -h pam --net ldapnet --privileged -it marcgc/hostpam19:auth /bin/bash
  ```
  
  * Requisits:
    
    * Instal·lar el paquet `nss-pam-ldapd`
    
    * Afegir les línies a `system-auth`:
      
      ```bash
      auth        sufficient    pam_ldap.so
      account     sufficient    pam_ldap.so
      password    sufficient    pam_ldap.so
      session     sufficient    pam_unix.so
      session     sufficient    pam_ldap.so
      ```
    
    * Arreglar el fitxer `nslcd.conf`:
      
      ```bash
      uri ldap://ldapserver
      base dc=edt,dc=org
      ```
    
    * Arreglar el fitxer `nsswitch.conf`:
      
      ```bash
      # Amb aquest ordre dels elements indiquem que primer miri als fitxers locals i, si no el troba, ho pregunti al servidor ldap. Si volguèssim que primer preguntés al servidor només hem de ficar-ho primer
      passwd:      files ldap systemd
      shadow:      files ldap
      group:       files ldap systemd
      ```



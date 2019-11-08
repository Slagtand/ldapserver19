# Provaldap 2019

[git de l'assignatura](https://github.com/Slagtand/ldapserver19)

## Marc Gómez Cardona

## isx47797439

## HISX 2 2019-2020

**Provaldap** servidor ldap amb la base de dades dc=marc,dc=cat

* Creació base de dades dc=marc,dc=cat
  
  ```
  database mdb
  suffix "dc=marc,dc=cat"
  rootdn "cn=Manager,dc=marc,dc=cat"
  rootpw secret
  directory /var/lib/ldap.marc.cat
  index objectClass                       eq,pres
  access to * by self write by * read
  # access to * by self write by * search
  ```

* Creació dades de marc.cat [marc.cat.ldif](./marc.cat.ldif)

* Per a descarregar aquesta imatge:
  
  ```bash
  docker pull/run marcgc/provaldap:2019 
  docker pull/run marcgc/provaldap:latest
  ```



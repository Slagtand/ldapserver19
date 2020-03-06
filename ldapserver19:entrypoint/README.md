## ldapserver19:entrypoint

Servidor ldap amb entrypoint amb diferents opcions d'arrencada





```bash
docker run --rm --name ldap.edt.org -h ldap.edt.org -v ldap-data:/var/lib/ldap -v ldap-config:/etc/openldap -d marcgc/ldapserver19:entrypoint initdb

docker run --rm --name ldap.edt.org -h ldap.edt.org -v ldap-data:/var/lib/ldap -v ldap-config:/etc/openldap -d marcgc/ldapserver19:entrypoint initdbedt

docker run --rm --name ldap.edt.org -h ldap.edt.org -v ldap-data:/var/lib/ldap -v ldap-config:/etc/openldap -d marcgc/ldapserver19:entrypoint start

docker run --rm --name ldap.edt.org -h ldap.edt.org -v ldap-data:/var/lib/ldap -v ldap-config:/etc/openldap -d marcgc/ldapserver19:entrypoint

docker run --rm --name ldap.edt.org -h ldap.edt.org -v ldap-data:/var/lib/ldap -v ldap-config:/etc/openldap -it marcgc/ldapserver19:entrypoint listdn


```

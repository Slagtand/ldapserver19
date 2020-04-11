# Servidor ldap segur

## Generar certificats

### Generar claus privades del servidor

```bash
$ openssl genrsa -out cakey.pem 2048
$ openssl genrsa -out serverkey.pem 2048
```

### Generar certificat propi de la CA

```bash
[marc@localhost ldapserver19:tls]$ openssl req -new -x509 -nodes -sha1 -days 365 -key cakey.pem -out cacert.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:ca
State or Province Name (full name) []:Barcelona
Locality Name (eg, city) [Default City]:Barcelona
Organization Name (eg, company) [Default Company Ltd]:Veritat Absoluta
Organizational Unit Name (eg, section) []:Certificats
Common Name (eg, your name or your server's hostname) []:VeritatAbsoluta
Email Address []:admin@edt.org
```

### Generar un certificat request per enviar a la certificadora CA

```bash
[marc@localhost ldapserver19:tls]$ openssl req -new -key serverkey.pem -out servercert.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:ca
State or Province Name (full name) []:Barcelona
Locality Name (eg, city) [Default City]:Barcelona
Organization Name (eg, company) [Default Company Ltd]:EDT
Organizational Unit Name (eg, section) []:departament informatica
Common Name (eg, your name or your server's hostname) []:ldap.edt.org
Email Address []:admin@edt.org

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:jupiter
An optional company name []:edt
```

### Creació CA

Nosaltres mateixos farem de CA

```bash
[marc@localhost ldapserver19:tls]$ cat ca.conf 
basicConstraints = critical,CA:FALSE
extendedKeyUsage = serverAuth,emailProtection
```

### Firma certificat com a CA

```bash
[marc@localhost ldapserver19:tls]$ openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in servercsr.pem -days 365 -sha1 -extfile ca.conf -CAcreateserial -out servercert.pem
Signature ok
subject=C = ca, ST = Barcelona, L = Barcelona, O = EDT, OU = departament informatica, CN = ldap.edt.org, emailAddress = admin@edt.org
Getting CA Private Key
```

## Configuracions per TLS

Per a generar una connexió segura encara que ens connectem a un port insegur hem de configurar alguns fitxers:

### Configuració del server

Al server hem de tocar els següents fitxers:

* fitxer `slapd.conf`: hem d'afegir les següents línies
  
  ```bash
  TLSCACertificateFile    /etc/openldap/certs/cacert.pem
  TLSCertificateFile      /etc/openldap/certs/servercert.pem
  TLSCertificateKeyFile   /etc/openldap/certs/serverkey.pem
  TLSVerifyClient         never
  TLSCipherSuite          HIGH:MEDIUM:LOW:+SSLv2
  ```

* fitxer `ldap.conf`: hem d'afegir (i editar on sigui necessari) les següents línies
  
  ```bash
  TLS_CACERT /etc/openldap/certs/cacert.pem
  SASL_NOCANON    on
  URI ldap://ldap.edt.org
  BASE dc=edt,dc=org
  ```

* Per finalitzar, editem l'arrencada del servei al fitxer `startup.sh`:
  
  ```bash
  /sbin/slapd -d0 -h "ldap:/// ldaps:/// ldapi:///"
  ```

### Configuració del client

Per la part del client, hem de seguir les següents indicacions.

* Si tenim el servidor en un docker, hem d'afegir l'entrada corresponent a `/etc/hosts`.

* Copiar el certificat de la CA que hem creat abans a `/etc/openldap/cacert.pem`.

* Editem el fitxer `/etc/openldap/ldap.conf`: indiquem on es troba el certificat anterior i toquem les següents línies
  
  ```bash
  TLS_CACERT /etc/openldap/cacert.pem
  TLS_REQCERT allow
  
  URI ldap://ldap.edt.org
  BASE dc=edt,dc=org
  
  SASL_NOCANON on
  ```

## Comprovacions

Comprovem amb les ordres `ldapsearch` i `openssl` si ho hem fet tot correctament:

* Amb `ldapsearch` hi afegirem l'opció `-ZZ` que, bàsicament, executa TLS i **requereix** que l'operació sigui satisfactoria per executar l'ordre.

```bash
[root@localhost ldapserver19:tls]# ldapsearch -x -LLL -ZZ -h ldap.edt.org -b 'dc=edt,dc=org' dn
dn: dc=edt,dc=org

dn: ou=usuaris,dc=edt,dc=org

dn: cn=Pau Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Pere Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Anna Pou,ou=usuaris,dc=edt,dc=org

...

# Amb -H indiquem una URI
[root@localhost ldapserver19:tls]# ldapsearch -x -LLL -H ldaps://ldap.edt.org dn
dn: dc=edt,dc=org

dn: ou=usuaris,dc=edt,dc=org

dn: cn=Pau Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Pere Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Anna Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Marta Mas,ou=usuaris,dc=edt,dc=org

dn: cn=Jordi Mas,ou=usuaris,dc=edt,dc=org

...
```

* Amb `openssl` comprovem que connecta amb el servidor i els certificats d'aquest

```bash
[root@localhost ldapserver19:tls]# openssl s_client -connect ldap.edt.org:636
CONNECTED(00000003)
depth=1 C = ca, ST = Barcelona, L = Barcelona, O = Veritat Absoluta, OU = Certificats, CN = VeritatAbsoluta, emailAddress = admin@edt.org
verify error:num=19:self signed certificate in certificate chain
verify return:1
depth=1 C = ca, ST = Barcelona, L = Barcelona, O = Veritat Absoluta, OU = Certificats, CN = VeritatAbsoluta, emailAddress = admin@edt.org
verify return:1
depth=0 C = ca, ST = Barcelona, L = Barcelona, O = EDT, OU = departament informatica, CN = ldap.edt.org, emailAddress = admin@edt.org
verify return:1
---

```

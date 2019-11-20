# PAM (Pluggable Authentication Modules)

**PAM** és un conjunt de llibreries que proporciona una api per **autenticar** aplicacions (servei). Els *clients* de **PAM** són les aplicacions que tenen que autenticar.

Això vol dir que el programa(aplicació) utilitza **PAM** i aquest ja utilitza l'autentificació que se l'hi hagi assignat (contrasenya, empremta...)

Una aplicació **pam aware** és una aplicació que sap que farà l'autentificació amb el pam al fitxer `/etc/pam.conf`.

Podem sapiguer si una aplicació es **pam aware** mirant si en el seus requisits existeix algún mòdul pam.

* Això ho mirem amb l'ordre `ldd` (list dinamic dependencies):
  
  ```bash
  ➜  ldd /usr/bin/chfn     
      linux-vdso.so.1 (0x00007ffc98950000)
      libpam.so.0 => /lib/x86_64-linux-gnu/libpam.so.0 (0x00007fe8f2566000)
      libpam_misc.so.0 => /lib/x86_64-linux-gnu/libpam_misc.so.0 (0x00007fe8f2561000)
  ....
  ```

## Directoris de configuració

* `/etc/pam.d/`: Directori on es troben els fitxers de configuració necessaris dels mòduls.

* `/etc/pam.conf`: Fitxer de configuració.
  
  ```bash
  #%PAM-1.0
  #type       control     argument
  auth       sufficient   pam_rootok.so
  auth       include      system-auth
  account    include      system-auth
  password   include      system-auth
  session    include      system-auth
  ```

* Els mòduls de pam instal·lats es troben a `/usr/lib64/security/`.

Els fitxers `.so` (shared object) fan referència als mòduls i poden tindre, o no, arguments.

```bash
[root@pam pam.d]# cat /etc/pam.d/system-auth 
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so
auth        sufficient    pam_unix.so try_first_pass nullok
auth        required      pam_deny.so

account     required      pam_unix.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so try_first_pass use_authtok nullok sha512 shadow
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
```

## Tipus (types)

PAM té 4 types diferents: `auth, account, password, session`.

* `auth`: autenticació d'usuari, qui sóc.

* `account`: permisos de modificació, què puc fer

* `password`: regles per canviar el password

* `session`: regles per fer al iniciar i tancar la sessió

**Important**: PAM no és un servei, al fer un canvi als fitxers s'aplica inmediatament:

```bash
#%PAM-1.0
auth       optional     pam_echo.so [auth: %h %s %t %u]
auth       required     pam_permit.so
auth       sufficient   pam_unix.so
account    optional     pam_echo.so [auth: %h %s %t %u]
account    sufficient   pam_permit.so

```

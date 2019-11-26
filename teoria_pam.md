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

## Controls

L'opció de controls té uns alies (**required**, **requisite**, **sufficient**, **optional**) amb una sèrie d'opcions predefinides més habituals.

```bash
required
[success=ok new_authtok_reqd=ok ignore=ignore default=bad]
#
requisite
[success=ok new_authtok_reqd=ok ignore=ignore default=die]
#
sufficient
[success=done new_authtok_reqd=done default=ignore]
#
optional
[success=ok new_authtok_reqd=ok default=ignore]
```

* `ignore`: Ignora aquesta opció

* `bad`: Marca com **fallo** i **segueix** evaluant.

* `die`: Marca com **fallo** i **deixa** d'evaluar.

* `ok`: Marca com **positiu** i **segueix** evaluant.

* `done`: Marca com **positiu** i **deixa** d'evaluar.

* `N`: numero de salts que farà, per exemple *success=2* saltarà dos cops.

* `reset`: Reseteja els valors anteriors.

### Controls predefinits

* `required`: Aquesta opció sempre tindrà que donar **true**. Si dona **false** fallarà però **segueix** preguntant a la següent regla.

* `requisite`: Aquesta opción ha de donar **true**. Si dona **false** finalitza, no passa a la següent regla i surt.

* `sufficient`: Si dona **true** ja no evalua més del stack. Si dona **false** ho ignora i segueix amb la següent regla del stack.

* `optional`: Intentarà fer el que se li demana, tant si dona true/false i no afectarà a les demés regles, a no ser que sigui la única a evaluar.

* `include`: Inclou altres mòduls de regles que es troben a altres fitxers i les tracta com si fóssin al mateix fitxer.

* `substack`: Com l'**include** però té un comportament diferent si troba un *done/die*.

### Diferències entre include/substack

Tot i que tots dos fan el "mateix" tenen un comportament diferent quan troben un *done/die*.

* En el cas de l'**include** quan troba un *done/die* **finalitza** l'evaluació del stack en el que es troba. En el següent cas, en el moment que trobi un dels dos **deixarà** d'evaluar les regles que **ha importat i el propi stack on es troba**, per això no mostrarà el segon echo i si el del **account**.
  
  ```bash
  auth optional pam_echo.so [ executem el include ]
  auth include proves
  auth optional pam_echo.so [ amb l'include això no surt ]
  
  account optional pam_echo.so [ això surt si o si perque és un altre stack ]
  ```

* Al contrari, amb el **substack** només finalitza el stack de les regles **importades** i **segueix** evaluant les següents. Amb l'exemple anterior mostrarà tots els echos, perquè l'últim **auth** no ha estat importat

### Exemples include/substack

A `/etc/pam.d/`:

```bash
# Original

auth optional pam_echo.so [ executem el include ]
auth include/substack  proves
auth required pam_unix.so
auth optional pam_echo.so [ amb l'include això no surt ]

account optional pam_echo.so [ això surt si o si perque és un altre stack ]
account include proves
account sufficient pam_permit.so

# file proves

auth sufficient pam_permit.so

account optional pam_echo.so [ aixo es un stack extern i un tipus diferent a auth ]
```

## Arguments

### Contrasenyes

Els arguments tipus `pam_unix.so, pam_ldap.so, pam_mount.so...` que requereixen contrasenya tenen diferents **atributs** per gestionar-les.

* Per defecte si no té atributs es demanarà contrasenya.

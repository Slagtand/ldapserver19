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
* `try_first_pass`: Si s'ha introduït una contrasenya anteriorment la fa servir, si no la demana.
* `use_first_pass`: Fa servir la contrasenya introduïda anteriorment. Si no se n'ha introduït cap no en farà servir.
* `nullok`: Permet l'accés a usuaris sense contrasenya.

`password requisite pam_pwquality.so` estableix les regles per a definir condicions de les contrasenyes.

`/etc/security/pwquality.conf` és el fitxer de les condicions.

### Restriccions

Apliquem les restriccions amb `pam_succeed_if.so`.

```bash
# Si l'usuari és pere
auth required pam_succeed_if.so user = pere
# Si l'usuari no és pere
auth required pam_succeed_if.so user != “pere”
# Si té un uid major que 1000
auth required pam_succeed_if.so uid > 1000
```

* Una altre forma de restringir és creant un control propi.

* En el següent exemple trobem que, si l'uid de l'user és `uid=1001` saltarà una línia i se li denegarà l'accés pel `pam_deny.so`. En cas de que no ho sigui s'ignora la línia del `pam_succeed_if.so` i s'evaluarà la següent línia.
  
  ```bash
  # Si l'user té d'uid 1001 el denega, si no accedeix
  auth [success=1 default=ignore] pam_succeed_if.so debug uid = 1001
  auth sufficient pam_permit.so
  auth sufficient pam_deny.so
  ```

També podem aplicar restriccions amb el temps amb el mòdul `pam_time.so`.

Sol funciona al stack **account** i junt amb el fitxer `/etc/security/time.conf`.

* La sintaxi és la següent `services;ttys;users;times`
  
  * `services`: Fa referència als serveis que afectarà.
  
  * `ttys`: Fa referència als ttys on s'aplicarà. Per defecte ho deixarem per a tots.
  
  * `users`: Fa referència a l'user o usuaris que es veuràn afectats.
  
  * `times`: El temps (dia/dies) amb les hores. Si volem ficar dies seguits ho haurem de fer amb més d'una regla (des de la hora x fins les 12 per a un dia, i des de les 12 de l'altre dia fins el que volguem)

* En el següent exemple bloquejem a l'user `local1` de 8h a 24h tota la setmana:
  
  ```bash
  services;ttys;users;times
  chfn;*;local1;Al0800-2400
  # De 8h del dilluns a les 10h del dimarts
  chfn;*;local1;Mo0800-2400
  chfn;*;local1:Tu0000-1000
  ```

* Hi han diferents combinacions:
  
  ```bash
  Cada dia té el seu nom:
      Mo = Dilluns
      Tu = Dimarts
      We = Dimecres
      Th = Dijous
      Fr = Divendres
      Sa = Dissabte
      Su = Diumenge
  També hi han agrupacions predefinides:
      Wk = Dies laborals (dilluns-divendres)
      Wd = Cap de setmana (dissabte-diumenge)
  Tambe podem definir agrupacions (l'ordre d'aquests és indiferent), tenint en ćompte que dos dies repetits s'anulen:
      MoMo = Al ser repetit s'anula
      MoWk = Tots els dies laborables menys el dilluns
      AlFr = Tots els dies excepte divendres.
  El rang de les hores és un rang tipus HHMM-HHMM en mode 24H
  ```

## Homedir

Podem indicar que, al iniciar l'usuari una sessió, se li crei el home si no el té.

Es fica al stack de **session**.

```bash
# Fitxer system-auth
session     required      pam_mkhomedir.so silent umask=0007
```

## Montatges

Amb `pam_mount.so` podem crear punts de muntatge de diferents serveis.

Ha d'estar al stack d'**auth** i **session** amb el control principal, abans de **sufficient** o **included**.

```bash
# Fitxer system-auth
auth    optional    pam_mount.so
auth    sufficient  pam_ldap.so use_first_pass
auth    required    pam_unix.so use_first_pass
account sufficient  pam_ldap.so
session optional    pam_mount.so
```

**Important**: Si ho volem executar a un contàiner l'hem d'arrencar amb l'opció `--privileged`, si no no podrà montar res.

Els volums a montar es defineixen a `/etc/security/pam_mount.conf.xml`.

```bash
# tmpfs
<volume    user="*"     fstype="tmpfs"     mountpoint="~/tmp"
       options="size=100M,uid=%(USER),mode=0775" />
# nfs
<volume user="*" fstype="nfs" server="fileserver" path="/home/%(USER)" mountpoint="~" />

# sshfs
<volume user="*" fstype="fuse" path="sshfs#%(USER)@fileserver:" mountpoint="~" />

# smbfs
<volume user="user" fstype="smbfs" server="krueger" path="public"
mountpoint="/home/user/krueger" />
```

* Per a exportar primer hem d'indicar-ho a `/etc/exports`:
  
  ```bash
  /usr/share/man *(ro,sync)
  /usr/share/doc *(ro,sync)
  ```

* Podem sapiguer què estem exportant amb l'ordre `exportfs -s`.

## Exemple de *system-auth* per a ldap

* Afegim les línies `pam_ldap.so` a `/etc/pam.d/system-auth`

```bash
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so
auth        optional      pam_mount.so
auth        sufficient    pam_unix.so try_first_pass nullok
auth        sufficient    pam_ldap.so try_first_pass
auth        required      pam_deny.so

account     sufficient      pam_unix.so
account     sufficient    pam_ldap.so
account     required      pam_deny.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so try_first_pass use_authtok nullok sha512 shadow
password  sufficient      pam_ldap.so try_first_pass
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_mkhomedir.so
session     optional      pam_mount.so
session     sufficient      pam_unix.so
session     sufficient      pam_ldap.so
```

* Afegim les dades del ldap al fitxer `/etc/nslcd.conf`
  
  ```bash
  # The uri pointing to the LDAP server to use for name lookups.
  # Multiple entries may be specified. The address that is used
  # here should be resolvable without using LDAP (obviously).
  #uri ldap://127.0.0.1/
  #uri ldaps://127.0.0.1/
  #uri ldapi://%2fvar%2frun%2fldapi_sock/
  # Note: %2f encodes the '/' used as directory separator
  uri ldap://ldapserver
  
  # The distinguished name of the search base.
  base dc=edt,dc=org
  ```

* Canviem l'ordre per a que demani primer les dades al ldap en comptes dels fitxers locals a `/etc/nsswitch.conf`
  
  ```bash
  passwd:      ldap files systemd
  shadow:      ldap files
  group:       ldap files systemd
  ```

* Podem comprovar si ha funcionat amb l'ordre `getent passwd user`. Si ens dona la info de l'usuari ldap està tot correcte.

### Authconfig

`Authconfig` és una ordre que ens edita i configura directament el fitxer `system-auth` segons els paràmetres que li passem. Podem veure els paràmetres que li podem passar amb `authconfig --help` i `man authconfig`.

* Exemple d'ordre amb `authconfig` si volguèssim configurar el server per a que es comuniqui amb un server ldap sense tindre que tocar-ho manualment:
  
  ```bash
  authconfig --enableshadow --enablelocauthorize \
     --enableldap \
     --enableldapauth \
     --ldapserver='ldapserver' \
     --ldapbase='dc=edt,dc=org' \
     --enablemkhomedir \
     --updateall
  ```

* `enableldap` modifica els fitxer `nsswitch.conf` i `nslcd.conf` per a tindre accés al servidor ldap.

* `enableldapauth` afegeix les línies `pam_ldap.so` al fitxer `system-auth`.

* `enablemkhomedir` afegeix `pam_mkhomedir.so` al fitxer `system-auth`.

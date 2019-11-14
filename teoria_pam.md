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



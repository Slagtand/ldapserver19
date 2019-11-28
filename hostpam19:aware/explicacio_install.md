# Examen hostpam19:aware

## Marc Gómez

## isx47797439 HISX2





* Descarreguem/executem el container:
  
  ```bash
  docker run --rm --name hostpam -h hostpam -it marcgc/hostpam19:aware /bin/bash
  ```

# Part 1 aplicació pam aware

Primer necessitem descarregar Python-PAM (en aquest cas ja ha sigut descarregat) i descomprimir-lo per a poguer accedir a ell.

Per a validar els usuaris (prèviament creats) executem el fitxer *pamaware.py* (a la carpeta /opt/docker/) on importarem el mòdul pam previament descarregat. Si el resultat és 0, l'usuari és vàlid. Si no, no ho és. En qualsevol cas ho mostra per pantalla

```bash
# Exemple user vàlid
[root@hostpam docker]# python3 pamaware.py 
Nom usuari: marc
Passwd: marc
0 Success
Usuari vàlid
# Exemple user invàlid
[root@hostpam docker]# python3 pamaware.py 
Nom usuari: joan
Passwd: joan
7 Authentication failure
Usuari no vàlid
```



# Part 2 pam_mates

Necessitem descarregar el paquet necessari (*pam-python-versió*). També el tenim descarregat, pel que sol hem de descomprimir-lo.

Editem el fitxer `/etc/pam.d/chfn` per afegir les línies necessàries:

```bash
#%PAM-1.0
auth    optional        pam_echo.so [ auth --------- ]
auth    sufficient      pam_python.so /opt/docker/pam_mates.py

account optional        pam_echo.so [ account -------- ]
account sufficient      pam_python.so /opt/docker/pam_permit.py

password include        pam_deny.so
session  include        pam_deny.so

```

Necessitem 2 fitxers, pam_mates.py i pam_permit.py (el primer éstà basat en el segón) que ja els tenim a la carpeta /opt/docker/

És necessari canviar un valor de `/usr/include/features.h` si no donarà un error al compilar-ho:

```bash
# Línia 201, canviem 700 per 600
# define _XOPEN_SOURCE 600
```

Si ens ha compilat bé amb el make tindrem el fitxer *pam_python.so* a la carpeta *src*. El copiem on hi han els mòduls de pam.

Accedim a l'user anna:

```bash
# Si introduim la resposta correcta ens deixarà canviar-ho
[anna@hostpam pam-python-1.0.7]$ chfn 
Changing finger information for anna.
Name []: 1
Office []: 1
Office Phone []: 1
Home Phone []: 1


 auth --------- 
Quant fan 3*2?
6
 account -------- 
Finger information changed.
# Si la fiquem malament, ens denegarà l'accés
[anna@hostpam pam-python-1.0.7]$ chfn 
Changing finger information for anna.
Name [1]: 2
Office [1]: 2
Office Phone [1]: 2
Home Phone [1]: 2


 auth --------- 
Quant fan 3*2?
4
 account -------- 
chfn: Permission denied
chfn: changing user attribute failed: Permission denied
```



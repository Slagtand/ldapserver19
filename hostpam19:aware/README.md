# Examen hostpam19:aware

## Marc Gómez

## isx47797439 HISX2

[Repositori GitHub](https://github.com/Slagtand/ldapserver19/tree/master/hostpam19:aware)

[Repositori DockerHub](https://hub.docker.com/repository/docker/marcgc/hostpam19/general)

* Descarreguem/executem el container:
  
  ```bash
  docker run --rm --name hostpam -h hostpam -it marcgc/hostpam19:aware /bin/bash
  ```

# Part 1 aplicació pam aware

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

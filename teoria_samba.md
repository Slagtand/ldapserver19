# Samba

Samba és un protocol de compartiment de directoris en xarxa, prové del protocol smb de Windows, actualment **cifs** (d'aquí el nom).

Té dos dimonis: `smbd` i `nmbd`.

* `smbd`: shares, files, print...

* `nmbd`: resolució de noms (dns).

* Els ports que fa servir són:
  
  ```bash
  139/tcp open  netbios-ssn
  445/tcp open  microsoft-ds
  ```

* Quan és un server Linux, simula ser un dispositiu Windows.

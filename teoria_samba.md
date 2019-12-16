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

## Diferents rols

* `stand alone`: No depèn de ningú, van a la seva. El host pot montar directoris remots i s'administra ell mateix.

* `servidor`: Ofereix algún servei a algún altre dispositiu. És un *stand alone* que ofereix un servei especial.

* `controlador de domini`: Pot ser `PDC` (*Primary Domain Controler*) o `DC`(*Domain Controler*).

## Tipologia de xarxa

* `P2P`: **Peer to peer**, una xarxa entre iguals.

* `Client/Server`: Administració centralitzada.

## Organització

* `workgroup`: Van al seu aire però pertanyen a un grup.

* `domini`: Pertanyen a un domini que ha de donar autorització.

//server/recurs -> Es denomina UNC (únic)

`$` al final del recurs indica que és un recurs **ocult**.

## Linux amb Samba

* `Client de samba`: per conectar a un servidor samba windows.

* `Servidor samba`: per compartir un recurs.

* Pot fer de controlador de domini.

## Ordres Samba

* `testparm`: Test de configuració de samba, ens permet veure què estem compartint.

* `smbtree`: Funciona per **broadcast** i mostra els equips que estàn compartint a la xarxa.

```bash
smbtree
# Veure el domini
smbtree -D
# Veure el server
smbtree -S
```

* `smbclient`: És la ordre client que fem servir per conectar a un recurs.

```bash
# Conectar al recurs manpages (per defecte conectem amb l'user actual)
smbclient //samba/manpages
# Conectar amb user anònim
smbclient -N //samba/manpages
# Conectem amb l'user ramon (ens demanarà password)
smbclient //samba/manpages -U ramon
# Conectem amb l'user ramon especificant la password després de %
smbclient //samba/manpages -U ramon%tururu
# Debug amb rang de 1-9
smbclient -d1 //samba/public
# Un cop conectats podem pujar/baixar entre altres ordres
smb: \> get file nounom
smb: \> put file nounom
```

* `smbget`: Descarrega directament el que volem, similar a `wget`.

```bash
smbget smb://samba/documentation/xz/file
# Podem especificar copiar una carpeta de forma recursiva
smbget -R smb://samba/documentation/
```

* `nmblookup`: Mostra el estat del servidor

```bash
# Per IP
nmblookup -A 172.18.0.2
# Per nom de server
nmblookup -S samba
```

* `smbclient` i `smbget` fan resolució per `nmb`.

* `mount`, al contrari, fa servir el `dns`. Degut que són diferents no sabrà fer la resolució de nom. Per això, ho fem servir la IP del servidor o editem `/etc/hosts`. Hem d'especificar el tipus `-t` i l'user `-o`.

```bash
mount -t cifs -o guest //172.18.0.2/public /mnt
```

## Accés gràfic

També podem accedir, des de l'explorador d'arxius, a un recurs.

```bash
smb://samba/public
```

## Configuració i recursos del servidor samba

* `/etc/samba/lmhosts` equival a `/etc/hosts`

* `/etc/samba/smb.conf` és la configuració de samba.

## Usuaris

Samba té els **seus propis** usuaris, però es recolza amb usuaris unixs **existents**.

```bash
useradd lila # En cas de que no estigui ja creat
smbpasswd -a lila # Afegim l'user a samba
```

* `pdbedit`: Edita o llista els usuaris samba

```bash
pdbedit -L
    lila:1003:
    roc:1005:
    patipla:1004:
    pla:1006:
```

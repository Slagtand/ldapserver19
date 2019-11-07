# Instal·lació de docker

```bash
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
# Si volem fer servir docker sense ser root
usermod -aG docker fedora
```

# Comandes bàsiques de docker

```bash
# Veiem les imatges que tenim
docker images

REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
docs/docker.github.io     latest              8ff778b86a81        9 days ago          1.94GB
marcgc/ldapserver19       schema              3f5d341af3b5        2 weeks ago         454MB
marcgc/ldapserver19       acl                 8847b35465e9        2 weeks ago         454MB
portainer/portainer       latest              4cda95efb0e4        3 weeks ago         80.6MB
marcgc/ldapserver19       multi               2d4116be1a3c        4 weeks ago         454MB
ldapserver19              base                008f0c84b003        5 weeks ago         454MB
fedora                    27                  f89698585456        8 months ago        236MB
edtasixm06/phpldapadmin   latest              f960bc4852a7        22 months ago       526MB
# Veure els containers EXECUTANT-SE
docker ps
docker container ls
# Veure tots els containers
docker ps -a
docker container ls -a

CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS                   PORTS               NAMES
0748c7b53e31        docs/docker.github.io:latest   "/bin/sh -c 'echo -e…"   9 days ago          Exited (0) 9 days ago                        vigorous_torvalds
f85e75ee5f98        portainer/portainer            "/portainer"             9 days ago          Exited (2) 8 days ago                        dazzling_poincare
0dddfee0ebe9        fedora:27                      "/bin/bash"              13 days ago         Exited (0) 13 days ago                       affectionate_engelbart
# Descarrega una imatge SENSE crear un container, usuari opcional (agafarà la que té per defecte docker)
docker pull marcgc/hello-world
# Crea un nou tag
docker tag hello-world hello-world:noutag
# Esborra una imatge
docker rmi hello-world:noutag
# Esborra el container
docker rm nom-container
```

# Accions contra els containers

```bash
# Crea (en el cas de que no el tinguem) i executa un container
docker run hello-world
    # L'executem de forma interactiva
docker run -it fedora:27 /bin/bash
# L'executem al foreground sense ser interactiu i que quan finalitzi s'esborri automàticament
docker run --rm -d marcgc/ldapserver19 /sbin/slapd -d1
# MATEM un container
docker kill fedora:27
# Accions generals com start/stop, pause/unpause
docker start/stop/pause/unpause fedora:27
# Mostra els processos que s'estàn executant en el container especificat
docker top nom-container

UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                7619                7602                0                   11:54               pts/0               00:00:00            /bin/bash
# Ataquem a un container que s'està executant
docker attach nom-container
# Executem una ordre des del host
docker exec -it nom-container ps ax
```

# Paquets útils per usar dins el container

```bash
dnf install -y procps iproute tree nmap mlocate man
dnf update vi
dnf install -y vim
```

# Pujar una imatge a dockerhub

```bash
# Primer configurem el login
docker login
# Guardem el container en una nova imatge
docker commit nom-container nom-nova-imatge
docker commit nom-container mychispas
# Creem un nou tag
docker tag imatge:latest marcgc/mychispas:latest
# Pujem l'imatge amb un push
docker push marcgc/mychispas:latest
# Usualment se sol dir latest com l'última actualització, però li podem donar el nom que volguem i es guardarà com una altre versió
```



























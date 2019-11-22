FROM fedora:27

LABEL version="1.0"
LABEL autor="@slagtand"
LABEL subject="hostpam19:scratch"

RUN dnf -y install vim passwd authconfig \
        nss-pam-ldapd openldap-clients
RUN mkdir /opt/docker

COPY * /opt/docker/

RUN chmod +x /opt/docker/startup.sh
WORKDIR /opt/docker/

CMD /opt/docker/startup.sh
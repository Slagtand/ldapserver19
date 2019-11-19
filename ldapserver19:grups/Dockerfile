# ldapserver
FROM fedora:27
LABEL version="1.0"
LABEL author="@marcgc"
LABEL subject="ldap server"
RUN dnf -y install openldap-servers openldap-clients vim procps iproute nmap util-linux-user finger passwd
RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/startup.sh
WORKDIR /opt/docker
CMD /opt/docker/startup.sh

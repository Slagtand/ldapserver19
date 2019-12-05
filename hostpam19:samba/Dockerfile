# Version: 0.0.1
# @edt M06 2019-2020
# samba
# -------------------------------------
FROM fedora:27
LABEL author="@marcgc"
LABEL description="Hostpam19:samba server 19-20"
RUN dnf -y install vim samba-client cifs-utils authconfig nss-pam-ldapd passwd pam_mount
RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/install.sh /opt/docker/startup.sh
WORKDIR /opt/docker
CMD ["/opt/docker/startup.sh"]


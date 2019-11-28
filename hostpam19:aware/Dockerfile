FROM fedora:27

LABEL version="0.1"
LABEL autor="@slagtand"
LABEL subject="hostpam19:aware"

RUN dnf install -y vim util-linux-user finger passwd make
RUN mkdir /opt/docker

COPY * /opt/docker/

#RUN tar xvzf ./python-pam-1.8.4.tar.gz
RUN chmod +x /opt/docker/startup.sh
WORKDIR /opt/docker/

CMD /opt/docker/startup.sh
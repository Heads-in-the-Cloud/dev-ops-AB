FROM docker.io/fedora:35

RUN yum update -y
RUN yum install -y --skip-broken openssh-server
RUN yum clean all

RUN systemctl start sshd
RUN systemctl enable sshd
RUN systemctl status sshd
EXPOSE  22

WORKDIR /opt/app

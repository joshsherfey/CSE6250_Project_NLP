FROM centos:7

ENV container docker

ADD http://www.apache.org/dist/bigtop/stable/repos/centos7/bigtop.repo /etc/yum.repos.d/bigtop.repo

RUN sed 's@releases/1.3.0/centos@releases/1.2.0/centos@g' -i /etc/yum.repos.d/bigtop.repo

RUN yum install epel-release -y && \
    yum update -y && \
    yum makecache && \
    yum install openssh* wget axel bzip2 unzip gzip git gcc-c++ lsof \
      java-1.8.0-openjdk java-1.8.0-openjdk-devel \
      mariadb mysql-connector-java \
      sudo hostname -y && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;\
    mv -f /bin/systemctl{,.orig} ; \
    ln -sf /bin/{false,systemctl}




EXPOSE 22
# CMD ["/usr/sbin/sshd", "-D"]
CMD ["/bin/bash"]

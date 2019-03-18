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


# 0 SSH

# SSH service start
RUN ssh-keygen -A ; \
    mkdir -p /var/run/sshd ; \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd ; \
    sed 's@#UseDNS yes@UseDNS no@g' -i /etc/ssh/sshd_config # prevent stucks here >> SSH2_MSG_SERVICE_ACCEPT received
# SSH service end


ADD config/ssh /root/.ssh
RUN chown -R root:root /root/.ssh ; \
    chmod 0700 /root/.ssh ; \
    chmod 0600 /root/.ssh/{id_rsa,id_rsa.pub,authorized_keys}


EXPOSE 22
# CMD ["/usr/sbin/sshd", "-D"]
CMD ["/bin/bash"]

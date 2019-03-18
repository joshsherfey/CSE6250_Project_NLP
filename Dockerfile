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

# 1 Hadoop, Spark, .... from bigtop
RUN yum install zookeeper-server hadoop-yarn-proxyserver \
    hadoop-hdfs-namenode hadoop-hdfs-datanode \
    hadoop-yarn-resourcemanager hadoop-mapreduce-historyserver \
    hadoop-yarn-nodemanager \
    spark-worker spark-master \
    hbase-regionserver hbase-master hbase-thrift \
    hive-metastore pig -y && \
    yum clean all && \
    rm -rf /var/cache/yum

# 2. Configure JAVA_HOME, Scala, SBT etc.
RUN echo "export JAVA_HOME=/usr/lib/jvm/java" >> /etc/profile.d/bigbox.sh

ENV SCALA_VERSION 2.11.8
RUN yum -y localinstall https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.rpm

ENV SBT_VERSION 1.1.0
RUN wget --progress=dot:mega https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz ; \
    tar -xzf sbt-${SBT_VERSION}.tgz ; \
    rm -rf sbt-${SBT_VERSION}.tgz ; \
    mv sbt /usr/lib/ ; \
    ln -sf /usr/lib/sbt/bin/sbt /usr/bin/

# 3. Clone Materials to /bigdata-bootcamp
RUN git clone https://bitbucket.org/realsunlab/bigdata-bootcamp.git /bigdata-bootcamp

# 4. Add Extra Basic scripts
RUN git clone https://github.com/sunlabga/bigbox-scripts.git /scripts

# 7. Install Miniconda Python
RUN wget --progress=dot:mega https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
      chmod +x miniconda.sh && ./miniconda.sh -b -p /usr/local/conda3 && \
      rm -f miniconda.sh
ENV PATH /usr/local/conda3/bin:$PATH
RUN echo 'export PATH=/usr/local/conda3/bin:$PATH' >> /etc/profile.d/bigbox.sh
RUN conda install --yes numpy ipython
RUN pip install --no-cache-dir asciinema

# N. tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

EXPOSE 22
# CMD ["/usr/sbin/sshd", "-D"]
CMD ["/bin/bash"]

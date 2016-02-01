FROM centos:centos7
MAINTAINER Nebulr <james.meyer@nebulr.net>

RUN yum -y update; yum clean all
RUN yum -y install epel-release tar; yum clean all
RUN yum -y install wget

# install git
RUN yum -y update
RUN yum -y install git

# install maven
RUN wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
RUN sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
RUN yum install -y apache-maven

# install index
RUN git clone https://github.com/Stratio/cassandra-lucene-index.git
RUN cd cassandra-lucene-index
RUN mkdir /etc/cassandra
RUN mvn clean package -Pdownload_and_patch -Dcassandra_home=/etc/cassandra
RUN chmod +x /etc/cassandra/bin/*
RUN export PATH=$PATH:/etc/cassandra/bin
RUN chkconfig --add cassandra
RUN chkconfig cassandra on
RUN service cassandra start

### Cassandra
# 7000: C* intra-node communication
# 7199: C* JMX
# 9042: C* CQL
# 9160: C* thrift service

EXPOSE 7000 7199 9042 9160
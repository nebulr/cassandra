FROM centos:centos7
MAINTAINER Nebulr <james.meyer@nebulr.net>

RUN yum -y update; yum clean all
RUN yum -y install epel-release tar; yum clean all

# install and configure supervisor
RUN yum -y update && yum -y install supervisor && mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# install java
RUN cd /opt/
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz"
RUN tar xzf jdk-7u79-linux-x64.tar.gz
RUN cd /opt/jdk1.7.0_79/
RUN alternatives --install /usr/bin/java java /opt/jdk1.7.0_79/bin/java 2
RUN alternatives --config java
RUN alternatives --install /usr/bin/jar jar /opt/jdk1.7.0_79/bin/jar 2
RUN alternatives --install /usr/bin/javac javac /opt/jdk1.7.0_79/bin/javac 2
RUN alternatives --set jar /opt/jdk1.7.0_79/bin/jar
RUN alternatives --set javac /opt/jdk1.7.0_79/bin/javac

# install maven
RUN wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
RUN sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
RUN yum install -y apache-maven

# install cassandra
RUN echo '[datastax] name = DataStax Repo for Apache Cassandra baseurl = http://rpm.datastax.com/community enabled = 1 gpgcheck = 0' >> /etc/yum.repos.d/datastax.repo
RUN yum -y update && yum -y install dsc22.2.2.4 cassandra2.2.4;
RUN systemctl start cassandra;
RUN systemctl enable cassandra

# install lucenne
RUN yum -y install tomcat6 tomcat6-webapps tomcat6-admin-webapps
RUN chkconfig tomcat6 on
RUN service tomcat6 start
RUN sed  '/\<tomcat-users\>/a <role rolename="manager" /> /a
<role rolename="admin" /> /a
<user username="admin" password="secretPassword" roles="manager,admin" />' input
RUN service tomcat6 start
RUN wget http://www.us.apache.org/dist//commons/logging/binaries/commons-logging-1.2-bin.tar.gz
RUN tar zxf commons-logging-1.2-bin.tar.gz
RUN cd commons-logging-1.2-bin
RUN cp commons-logging-*.jar /usr/share/tomcat6/lib
RUN wget http://www.slf4j.org/dist/slf4j-1.7.14.tar.gz
RUN tar zxf slf4j-1.7.14.tar.gz
RUN cp slf4j-1.7.14/slf4j-*.jar /usr/share/tomcat6/lib
RUN wget http://www.us.apache.org/dist/lucene/java/5.4.1/lucene-5.4.1.tgz
RUN tar zxf lucene-5.4.1.tgz
RUN cp lucene-5.4.1/dist/lucene-5.4.1.war /usr/share/tomcat6/webapps/lucene.war
RUN mkdir /home/lucene
RUN cp -R lucene-5.4.1/example/lucene/* /home/lucene
RUN chown -R tomcat /home/lucene
RUN service tomcat6 restart

### Cassandra
# 7000: C* intra-node communication
# 7199: C* JMX
# 9042: C* CQL
# 9160: C* thrift service

EXPOSE 7000 7199 9042 9160
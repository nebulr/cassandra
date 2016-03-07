# Cassandra
#
# VERSION               1.0

FROM centos:centos7

# Install Java.
ENV JAVA_VERSION 8u31
ENV BUILD_VERSION b13

# Add source repositories
ADD src/epel7.repo /etc/yum.repos.d/epel7.repo
ADD src/datastax.repo /etc/yum.repos.d/datastax.repo
ADD src/epel-apache-maven.repo /etc/yum.repos.d/epel-apache-maven.repo

# Upgrading system
RUN yum -y upgrade

# Install Java, Install packages (sshd + supervisord + monitoring tools + cassandra)
RUN yum install -y wget tar openssh-server openssh-clients supervisor sysstat sudo git which openssl hostname apache-maven

# Downloading Java
RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm

RUN yum -y install /tmp/jdk-8-linux-x64.rpm

RUN alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000
RUN alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000
RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000

ENV JAVA_HOME /usr/java/latest
RUN yum install -y dsc22
RUN yum clean all

# Configure SSH server
# Create OpsCenter account
RUN mkdir -p /var/run/sshd && chmod -rx /var/run/sshd && \
	ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key && \
	sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
	sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
	useradd -m -G users,root -p $(openssl passwd -1 "opscenter") opscenter && \
	echo "%root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Config cassandra-lucene
RUN git clone https://github.com/Stratio/cassandra-lucene-index.git
RUN cd cassandra-lucene-index && mvn clean package && cp plugin/target/cassandra-lucene-index-plugin-*.jar /usr/share/cassandra/lib/

# Configure supervisord
ADD src/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log/supervisor

# Deploy startup script
ADD src/start.sh /usr/local/bin/start

# Necessary since cassandra is trying to override the system limitations
# See https://groups.google.com/forum/#!msg/docker-dev/8TM_jLGpRKU/dewIQhcs7oAJ
RUN rm -f /etc/security/limits.d/cassandra.conf

EXPOSE 7199 7000 7001 9160 9042
EXPOSE 22 8012 61621
CMD start

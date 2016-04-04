
# Cassandra
#
# VERSION               1.0

FROM centos:centos7

RUN echo "root:Docker!" | chpasswd

# Add source repositories
ADD src/epel7.repo /etc/yum.repos.d/epel7.repo
ADD src/datastax.repo /etc/yum.repos.d/datastax.repo

# Install Java, Install packages (sshd + supervisord + monitoring tools + cassandra)
RUN yum install -y wget tar openssh-server openssh-clients supervisor sysstat sudo which openssl hostname git
RUN yum clean all

# Install maven 3.3.3
RUN wget ftp://mirror.reverse.net/pub/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && tar zxvf apache-maven-3.3.9-bin.tar.gz -C /usr/local/ && rm -Rf apache-maven-3.3.9-bin.tar.gz && mv /usr/local/apache-maven-3.3.9 /usr/local/maven
ENV MAVEN_HOME /usr/local/maven
ENV PATH ${MAVEN_HOME}/bin:${PATH}
RUN ln -s /usr/local/maven/bin/mvn /usr/bin/mvn

RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u72-b15/jdk-8u72-linux-x64.rpm"
RUN rpm -Uvh jdk-8u72-linux-x64.rpm
RUN java -version

RUN yum install -y dsc30
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
RUN git clone https://github.com/nebulr/cassandra-lucene-index.git
RUN cd cassandra-lucene-index && mvn clean package -Pdownload_and_patch -Dcassandra_home=/etc/cassandra

# Configure supervisord
ADD src/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /data && chown -R cassandra:cassandra /data
RUN mkdir -p /saved_caches && chown -R cassandra:cassandra /saved_caches
RUN mkdir -p /commitlog && chown -R cassandra:cassandra /commitlog
RUN mkdir -p /hints && chown -R cassandra:cassandra /hints

# Deploy startup script
ADD src/start.sh /usr/local/bin/start

# Necessary since cassandra is trying to override the system limitations
# See https://groups.google.com/forum/#!msg/docker-dev/8TM_jLGpRKU/dewIQhcs7oAJ
RUN rm -f /etc/security/limits.d/cassandra.conf

EXPOSE 7199 7000 7001 9160 9042
EXPOSE 22 8012 61621
USER root
CMD start

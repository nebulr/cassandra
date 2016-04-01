#
# Oracle Java 8 Dockerfile
# Pull base image.
FROM ubuntu

# Install Java.
RUN \
  apt-get install -y software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Java, Install packages (sshd + supervisord + monitoring tools + cassandra)
RUN apt-get install software-properties-common && apt-add-repository universe
RUN apt-get update && apt-get install -y git maven
RUN cd /usr/share && wget http://downloads.datastax.com/datastax-ddc/datastax-ddc-3.4.0-bin.tar.gz && tar zxvf datastax-ddc-3.4.0-bin.tar.gz && mv datastax-ddc-3.4.0-bin.tar.gz cassandra

# Config cassandra-lucene
RUN git clone https://github.com/nebulr/cassandra-lucene-index.git
RUN cd cassandra-lucene-index && mvn clean package -Pdownload_and_patch -Dcassandra_home=/usr/share/cassandra

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

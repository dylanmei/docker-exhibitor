FROM openjdk:8-slim

RUN groupadd -g 1000 exhibitor \
 && useradd -r -m -u 1000 -g exhibitor exhibitor \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates procps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ZOOKEEPER
ENV ZOOKEEPER_VERSION=3.4.9 \
    ZOO_LOG_DIR=/var/log/zookeeper
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz" \
  | gunzip \
  | tar x -C /usr/ \
 && chown -hR exhibitor:exhibitor /usr/zookeeper-${ZOOKEEPER_VERSION} \
 && ln -s /usr/zookeeper-${ZOOKEEPER_VERSION} /usr/zookeeper \
 && mkdir -p /var/lib/zookeeper/transactions \
 && mkdir -p /var/lib/zookeeper/snapshots \
 && mkdir -p /var/log/zookeeper \
 && chown -hR exhibitor:exhibitor /var/lib/zookeeper \
 && chown -hR exhibitor:exhibitor /var/log/zookeeper

# EXHIBITOR
ENV EXHIBITOR_VERSION=1.6.0
ENV EXHIBITOR_COMMIT=775bd4a67e1150b31238ad69da532b1b88376e86
RUN mkdir -p /usr/exhibitor/lib \
 && curl -sL http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
  | gunzip \
  | tar x -C /tmp/ \
 && curl "https://raw.githubusercontent.com/Netflix/exhibitor/${EXHIBITOR_COMMIT}/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml" -o /usr/exhibitor/pom.xml \
 && MAVEN_OPTS="-Xms512m -Xmx1024m" /tmp/apache-maven-3.3.9/bin/mvn --batch-mode -f /usr/exhibitor/pom.xml package \
 && mv /usr/exhibitor/target/exhibitor-${EXHIBITOR_VERSION}.jar /usr/exhibitor/lib/exhibitor.jar \
 && chown -hR exhibitor:exhibitor /usr/exhibitor \
 && rm -rf /usr/exhibitor/target \
 && rm -rf /root/.m2 \
 && rm -rf /tmp/*

EXPOSE 2181 2888 3888 8080
WORKDIR /usr/exhibitor

ADD --chown=exhibitor:exhibitor default.properties exhibitor.properties

USER exhibitor:exhibitor
ENTRYPOINT ["java", "-jar", "lib/exhibitor.jar"]
CMD ["--hostname", "localhost", "--defaultconfig", "exhibitor.properties", "--configtype", "file"]

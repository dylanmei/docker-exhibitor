FROM openjdk:8-slim

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates procps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ZOOKEEPER
ENV ZOOKEEPER_VERSION=3.4.9
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz" \
  | gunzip \
  | tar x -C /usr/ \
 && ln -s /usr/zookeeper-${ZOOKEEPER_VERSION} /usr/zookeeper \
 && mkdir -p /var/lib/zookeeper/transactions \
 && mkdir -p /var/lib/zookeeper/snapshots

# EXHIBITOR
ENV EXHIBITOR_VERSION=1.5.6
ENV EXHIBITOR_COMMIT=5733dbb14229d6c43fa8a3df8ba49261de6d508a
RUN mkdir -p /usr/exhibitor/lib \
 && curl -sL http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
  | gunzip \
  | tar x -C /tmp/ \
 && curl "https://raw.githubusercontent.com/Netflix/exhibitor/${EXHIBITOR_COMMIT}/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml" -o /usr/exhibitor/pom.xml \
 && MAVEN_OPTS="-Xms512m -Xmx1024m" /tmp/apache-maven-3.3.9/bin/mvn --batch-mode -f /usr/exhibitor/pom.xml package \
 && mv /usr/exhibitor/target/exhibitor-${EXHIBITOR_VERSION}.jar /usr/exhibitor/lib/exhibitor.jar \
 && rm -rf /usr/exhibitor/target \
 && rm -rf /root/.m2 \
 && rm -rf /tmp/*

EXPOSE 2181 2888 3888 8080
WORKDIR /usr/exhibitor
COPY default.properties .

ENTRYPOINT ["java", "-jar", "lib/exhibitor.jar"]
CMD ["--hostname", "localhost", "--defaultconfig", "default.properties", "--configtype", "file"]

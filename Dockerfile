FROM tier/shibboleth_sp

MAINTAINER John Gasper <jgasper@unicon.net>

ENV JAVA_HOME=/opt/openjdk8

RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
    && rm /etc/shibboleth/sp-key.pem /etc/shibboleth/sp-cert.pem

RUN yum -y update \
    && yum -y install python-pip tar graphviz \
    && yum -y clean all

#Install Supervisord
RUN pip install --upgrade pip \
    && pip install supervisor

RUN java_version=8.0.172; \
    zulu_version=8.30.0.1; \
    echo 'Downloading the OpenJDK Zulu...' \ 
    && wget -q http://cdn.azul.com/zulu/bin/zulu$zulu_version-jdk$java_version-linux_x64.tar.gz \
    && echo "0a101a592a177c1c7bc63738d7bc2930  zulu$zulu_version-jdk$java_version-linux_x64.tar.gz" | md5sum -c - \
    && tar -zxvf zulu$zulu_version-jdk$java_version-linux_x64.tar.gz -C /opt \
    && ln -s /opt/zulu$zulu_version-jdk$java_version-linux_x64 $JAVA_HOME \
    && rm zulu$zulu_version-jdk$java_version-linux_x64.tar.gz

#Install Tomcat
RUN tomcat_version=8.0.52; \
    tomcat_hash=23ba3c005d2e1bff30360a7aca5882ba7acaef0001395b1f77eb182c1f9c6a48db7f39b9f71ebdfb20668eca32c5f03bf00364f77d47e368850a794f6d65ea56;\
    wget -q https://archive.apache.org/dist/tomcat/tomcat-8/v$tomcat_version/bin/apache-tomcat-$tomcat_version.tar.gz \
    && echo "$tomcat_hash  apache-tomcat-$tomcat_version.tar.gz" | sha512sum -c - \
    && tar -zxvf apache-tomcat-$tomcat_version.tar.gz -C /opt \
    && rm apache-tomcat-$tomcat_version.tar.gz \
    && ln -sf /opt/apache-tomcat-$tomcat_version/ /opt/tomcat \
    && rm -rf /opt/tomcat/webapps/

#Install midPoint
RUN midpoint_version=3.8; \
    wget -q https://evolveum.com/downloads/midpoint/$midpoint_version/midpoint-$midpoint_version-dist.tar.gz \
    && tar -zxvf midpoint-$midpoint_version-dist.tar.gz -C /opt \
    && rm midpoint-$midpoint_version-dist.tar.gz \
    && ln -sf /opt/midpoint-$midpoint_version/ /opt/midpoint \
    && mkdir -p /opt/midpoint/webapp/ \
    && cd /opt/midpoint/webapp/ \
    && /opt/openjdk8/bin/jar xvf /opt/midpoint/lib/midpoint.war \
    && rm /opt/midpoint/lib/midpoint.war

ADD http://central.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.11.0/log4j-core-2.11.0.jar /opt/tomcat/bin
ADD http://central.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.11.0/log4j-api-2.11.0.jar /opt/tomcat/bin
ADD http://central.maven.org/maven2/org/apache/logging/log4j/log4j-jul/2.11.0/log4j-jul-2.11.0.jar /opt/tomcat/bin

RUN cd /opt/tomcat/; \
    chmod -R +r * \
    && mkdir -p logs/ temp/ work/ conf/Catalina/localhost/ webapps/ /opt/midpoint/var/ \
    && rm -fr conf/logging.properties \
    && groupadd -r tomcat \
    && useradd -r -m -s /sbin/nologin -g tomcat tomcat \
    && chown -R tomcat:tomcat logs/ temp/ work/ webapps/ /opt/midpoint/var/
    
COPY container_files/httpd/* /etc/httpd/conf.d/
COPY container_files/shibboleth/* /etc/shibboleth/
COPY container_files/tier-support/ /opt/tier-support/
COPY container_files/tomcat/ /opt/tomcat/
COPY container_files/usr-local-bin/ /usr/local/bin/

RUN cp /dev/null /etc/httpd/conf.d/ssl.conf \
    && sed -i 's/LogFormat "/LogFormat "httpd;access_log;%{ENV}e;%{USERTOKEN}e;/g' /etc/httpd/conf/httpd.conf \
    && echo -e "\nErrorLogFormat \"httpd;error_log;%{ENV}e;%{USERTOKEN}e;[%{u}t] [%-m:%l] [pid %P:tid %T] %7F: %E: [client\ %a] %M% ,\ referer\ %{Referer}i\"" >> /etc/httpd/conf/httpd.conf \
    && sed -i 's/CustomLog "logs\/access_log"/CustomLog "\/tmp\/logpipe"/g' /etc/httpd/conf/httpd.conf \
    && sed -i 's/ErrorLog "logs\/error_log"/ErrorLog "\/tmp\/logpipe"/g' /etc/httpd/conf/httpd.conf \
    && echo -e "\nPassEnv ENV" >> /etc/httpd/conf/httpd.conf \
    && echo -e "\nPassEnv USERTOKEN" >> /etc/httpd/conf/httpd.conf

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["midpoint"]

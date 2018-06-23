CLASSPATH=/opt/tomcat/bin/*
JAVA_OPTS="-Dlog4j.configurationFile=/opt/tomcat/conf/log4j2.xml -DENV=$ENV -DUSERTOKEN=$USERTOKEN -Dmidpoint.home=/opt/midpoint/var -Djavax.net.ssl.trustStore=/opt/midpoint/var/keystore.jceks -Djavax.net.ssl.trustStoreType=jceks"
LOGGING_MANAGER=-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager
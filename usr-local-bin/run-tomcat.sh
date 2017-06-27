#!/bin/sh
export JAVA_HOME=/opt/openjdk8
export PATH=$PATH:$JAVA_HOME/bin

echo "Start Tomcat as PID 1"
exec /opt/tomcat/bin/catalina.sh run
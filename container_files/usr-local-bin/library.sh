#!/bin/sh

setupPipe() {
    if [ -e $1 ]; then
        rm $1
    fi
    mkfifo -m 666 $1
}

setupLoggingPipe() {
    # Make a "console" logging pipe that anyone can write too regardless of who owns the process.
    setupPipe /tmp/logpipe
    cat <> /tmp/logpipe &
}

# Make loggers pipes for the supervisord connected apps' console, so that we can prepend the streams.
setupMidpointLogPipe() {
    setupPipe /tmp/logmidpoint
    (cat <> /tmp/logmidpoint | awk -v ENV="$ENV" -v UT="$USERTOKEN" '{printf "midpoint;console;%s;%s;%s\n", ENV, UT, $0; fflush()}' &>/tmp/logpipe) &
}

setupHttpdLogPipe() {
    setupPipe /tmp/loghttpd
    (cat <> /tmp/loghttpd  | awk -v ENV="$ENV" -v UT="$USERTOKEN" '{printf "httpd;console;%s;%s;%s\n", ENV, UT, $0; fflush()}' &>/tmp/logpipe) &
}

setupShibdLogPipe() {
    setupPipe /tmp/logshibd
    (cat <> /tmp/logshibd | awk -v ENV="$ENV" -v UT="$USERTOKEN" '{printf "shibd;console;%s;%s;%s", ENV, UT, $0; fflush()}' &>/tmp/logpipe) &
}

setupTomcatLogPipe() {
    setupPipe /tmp/logtomcat
    (cat <> /tmp/logtomcat | awk -v ENV="$ENV" -v UT="$USERTOKEN" '{printf "tomcat;console;%s;%s;%s\n", ENV, UT, $0; fflush()}' &>/tmp/logpipe) &
}

setupSupervisordLogPipe() {
    setupPipe /tmp/logsuperd
    (cat <> /tmp/logsuperd | awk -v ENV="$ENV" -v UT="$USERTOKEN" '{printf "supervisord;console;%s;%s;%s\n", ENV, UT, $0; fflush()}' &>/tmp/logpipe) &
}

linkMidpointSecrets() {
    for filepath in /run/secrets/*; do
        local label_file=`basename $filepath`
        local file=$(echo $label_file| cut -d'_' -f 2)

        if [[ $label_file == midpoint_* ]]; then
            ln -sf /run/secrets/$label_file $1/$file
        elif [[ $label_file == shib_* ]]; then
            ln -sf /run/secrets/$label_file /etc/shibboleth/$file
        elif [[ $label_file == httpd_* ]]; then
            ln -sf /run/secrets/$label_file /etc/httpd/conf.d/$file
        elif [ "$label_file" == "host-key.pem" ]; then
            ln -sf /run/secrets/host-key.pem /etc/pki/tls/private/host-key.pem
        fi
    done
}

prepMidpoint() {
    setupLoggingPipe
    setupMidpointLogPipe
    setupHttpdLogPipe
    setupShibdLogPipe
    setupTomcatLogPipe
    setupSupervisordLogPipe

    cp /opt/tier-support/midpoint.xml /opt/tomcat/conf/Catalina/localhost/
}

prepConf() {
    local dest=
    linkMidpointSecrets /opt/midpoint/var
}
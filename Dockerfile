# inspired by https://github.com/hauptmedia/docker-jmeter  and
# https://github.com/hhcordero/docker-jmeter-server/blob/master/Dockerfile
FROM alpine:3.6

MAINTAINER Just van den Broecke<just@justobjects.nl>

ARG JMETER_VERSION="3.3"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

# Install extra packages
# See https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-272703023
# Change TimeZone TODO: TZ still is not set!
ARG TZ="Europe/Amsterdam"
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash py2-pip python \
        && pip install awscli \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
        && curl -L --silent https://jmeter-plugins.org/files/packages/jpgc-json-2.6.zip > /tmp/dependencies/jpgc-json-2.6.zip \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
        && unzip -oq "/tmp/dependencies/jpgc-json-2.6.zip" -d $JMETER_HOME \
	&& rm -rf /tmp/dependencies

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

COPY entrypoint.sh /

COPY runtest.sh ${JMETER_HOME}

COPY build_payload.py ${JMETER_HOME}

COPY transform_csv_result.py ${JMETER_HOME}

WORKDIR	${JMETER_HOME}

ENTRYPOINT ["/entrypoint.sh"]

CMD ${JMETER_HOME}/runtest.sh

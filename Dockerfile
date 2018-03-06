FROM openjdk:8-jdk-alpine
MAINTAINER Atlassian Bitbucket Server Team

ENV RUN_USER            daemon
ENV RUN_GROUP           daemon

# https://confluence.atlassian.com/display/BitbucketServer/Bitbucket+Server+home+directory
ENV BITBUCKET_HOME          /var/atlassian/application-data/bitbucket
ENV BITBUCKET_INSTALL_DIR   /opt/atlassian/bitbucket

VOLUME ["${BITBUCKET_HOME}"]

# Expose HTTP and SSH ports
EXPOSE 7990
EXPOSE 7999

WORKDIR $BITBUCKET_HOME

CMD ["/entrypoint.sh", "-fg"]
ENTRYPOINT ["/sbin/tini", "--"]

RUN apk update -qq \
    && update-ca-certificates \
    && apk add ca-certificates wget curl git git-daemon openssh bash procps openssl perl ttf-dejavu tini \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

COPY entrypoint.sh              /entrypoint.sh

COPY . /tmp

#ARG DOWNLOAD_URL=https://downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz

ARG BITBUCKET_VERSION=5.8.1
ARG INSTALL_PACKAGE=/tmp/latlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz

RUN mkdir -p  ${BITBUCKET_INSTALL_DIR} 


RUN tar -xz -f /tmp/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz --strip-components=1  -C "$BITBUCKET_INSTALL_DIR"
RUN cp /tmp/atlassian-extras-decoder-v2-3.3.0.jar ${BITBUCKET_INSTALL_DIR}/app/WEB-INF/lib
RUN cp /tmp/atlassian-extras-legacy-3.3.0.jar ${BITBUCKET_INSTALL_DIR}/app/WEB-INF/lib
RUN chown -R ${RUN_USER}:${RUN_GROUP} ${BITBUCKET_INSTALL_DIR}


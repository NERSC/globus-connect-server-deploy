FROM ubuntu:20.04

LABEL maintainer="support@globus.org"

ARG USE_UNSTABLE_REPOS
ARG USE_TESTING_REPOS

ARG REPO_PREFIX=https://downloads.globus.org/globus-connect-server
ARG REPO_SUFFIX=installers/repo/deb/globus-repo_latest_all.deb

ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND="noninteractive"

RUN \
    apt-get update                                                                                       ;\
    apt-get install -y curl gnupg dialog apt-utils sudo psmisc                                           ;\
    apt-get -y install tzdata                                                                            ;\
    if [ -n "$USE_UNSTABLE_REPOS" ]; then                                                                 \
        echo "Using unstable package repositories!"                                                      ;\
        curl -LOs $REPO_PREFIX/stable/$REPO_SUFFIX                                                       ;\
        dpkg -i globus-repo_latest_all.deb                                                               ;\
        sed -i /etc/apt/sources.list.d/globus-connect-server-unstable*.list -e 's/^# deb /deb /'         ;\
        sed -i /etc/apt/sources.list.d/globus-connect-server-stable*.list -e 's/^deb /# deb /'           ;\
    elif [ -n "$USE_TESTING_REPOS" ]; then                                                                \
        echo "Using testing package repositories!"                                                       ;\
        curl -LOs $REPO_PREFIX/testing/$REPO_SUFFIX                                                      ;\
        dpkg -i globus-repo_latest_all.deb                                                               ;\
        sed -i /etc/apt/sources.list.d/globus-connect-server-testing*.list -e 's/^# deb /deb /'          ;\
        sed -i /etc/apt/sources.list.d/globus-connect-server-stable*.list -e 's/^deb /# deb /'           ;\
    else                                                                                                  \
        echo "Using stable package repositories!"                                                        ;\
        curl -LOs $REPO_PREFIX/stable/$REPO_SUFFIX                                                       ;\
        dpkg -i globus-repo_latest_all.deb                                                               ;\
    fi                                                                                                   ;\
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add /usr/share/globus-repo/RPM-GPG-KEY-Globus         ;\
    apt-get update                                                                                       ;\
    apt-get install -y globus-connect-server54

COPY entrypoint.sh /entrypoint.sh

# These are the default ports in use by GCSv5.4. Currently, they can not be changed.
#   443 : HTTPD service for GCS Manager API and HTTPS access to collections
#  50000-51000 : Default port range for incoming data transfer tasks
EXPOSE 443/tcp 50000-51000/tcp

# Default command unless overriden with 'docker run --entrypoint'
ENTRYPOINT ["/entrypoint.sh"]
# Default options to ENTRYPOINT unless overriden with 'docker run arg1...'
CMD []

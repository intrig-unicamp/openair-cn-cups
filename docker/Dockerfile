FROM ubuntu:18.04

ARG GIT_TAG=2019.w47
ARG UID=1000
ARG GID=1000
ARG UNAME=oai-spgwu

WORKDIR /tmp/$UNAME

RUN apt-get update && \
      apt-get -y install sudo git

# TODO: Instead of clone, we should download only de dependencies.
# TODO: Remove repository in the end.
# TODO: Check if this really needed. vscode mount this on container.
RUN git clone --depth=1 --branch=$GIT_TAG https://github.com/OPENAIRINTERFACE/openair-cn-cups.git

RUN git clone --depth=1 --branch=master https://github.com/gabime/spdlog.git openair-cn-cups/build/ext/spdlog

RUN apt-get update && \
      apt-get -y install cmake 

RUN apt-get update && \
      apt-get -y install gcc g++ 

RUN apt-get update && \
      apt-get -y install libconfig++

RUN cd openair-cn-cups/build/scripts && \
    ./build_spgwu -I -f

RUN apt-get update && \
      apt-get -y install iproute2

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
      apt-get update && \
      apt-get -y install ansible

RUN apt-get update && \
      apt-get -y install iptables

RUN apt-get update && \
      apt-get -y install iputils-ping

RUN apt-get update && \
      apt-get -y install wget

# https://pcapplusplus.github.io/docs/install/build-source/linux#installation
RUN apt-get update && \
      apt-get -y install libpcap-dev && \
      git clone --depth=1 --branch=v19.12 https://github.com/seladb/PcapPlusPlus.git && \
      cd PcapPlusPlus && \
      ./configure-linux.sh --default && \
      make && \
      make install

# googletest v1.8.0 
RUN  wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz && \
      tar zxf release-1.8.0.tar.gz && \
      rm -f release-1.8.0.tar.gz && \
      cd googletest-release-1.8.0 && \
      cmake . && \
      make && \
      make install && \
      cd ..

RUN apt-get update \
      # Install Docker CE CLI
      # The idea is to run docker network connect inside the container
      && apt-get install -y apt-transport-https ca-certificates curl gnupg2 lsb-release \
      && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
      && echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
      && apt-get update \
      && apt-get install -y docker-ce-cli \
      # Install Docker Compose
      && LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")') \
      && curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
      && chmod +x /usr/local/bin/docker-compose

# Creates openair-cn-cups user. The password is the username. 
#RUN useradd -m openair-cn-cups && echo "openair-cn-cups:openair-cn-cups" | chpasswd && adduser openair-cn-cups sudo

# The user and group `$UNAME` is created.
# The user `$UNAME` is added to the both the `$UNAME` and `sudo` group.
# The `uid` and `gid` is set to the value of `999`.
# The home directory is set to `/home/$UNAME`. 
# The shell is set to `/bin/bash`.
# The `sed` command does inline updates to the `/etc/sudoers` file to allow `$UNAME` and `root` users passwordless access to the `sudo` group.
# The `sed` command disables the `#includedir` directive that would allow any files in subdirectories to override these inline updates.
# Ref: https://superuser.com/questions/1296533/sudo-inside-docker-on-fedora-ask-for-password-on-host-it-doesnt-ask-password/1491777#1491777
RUN echo "GUI=${GID} and UID=${UID}"

RUN groupadd -g ${GID} $UNAME && useradd -u ${UID} -g $UNAME -G sudo -m -s /bin/bash $UNAME && \
    sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "$UNAME ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Customized the sudoers file for passwordless access to the $UNAME user!" && \
    echo "$UNAME user:";  su - $UNAME -c id

# Persiste bash history
# https://code.visualstudio.com/docs/remote/containers-advanced#_persist-bash-history-between-runs
# FIXME: Do not forget to remove \ in the end of the last line
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
      && echo $SNIPPET >> "/root/.bashrc" \
      # [Optional] If you have a non-root user
      && mkdir /commandhistory \
      && touch /commandhistory/.bash_history \
      && chown -R $UNAME /commandhistory \
      && echo $SNIPPET >> "/home/$UNAME/.bashrc" 
 
RUN apt-get update && \
      apt-get -y install tcpdump
      
USER root
#USER $UNAME

CMD /bin/bash

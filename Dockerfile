################################################################################
#
# General installations & prerequisites
#
################################################################################

FROM jrei/systemd-ubuntu:22.04

ENV PHP_VERSION 8.2
ENV NODE_VERSION 18.16.1
ENV YARN_VERSION 1.22.5
ENV RUBY_VERSION_32 3.2.2
ENV RUBY_VERSION_DEFAULT ${RUBY_VERSION_32}
ARG FIREFOX_VERSION=74.0

ENV DEBIAN_FRONTEND=noninteractive

# "fake" dbus address to prevent errors
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common wget language-pack-en-base apt-transport-https dirmngr gpg-agent sudo && \
    add-apt-repository -y ppa:git-core/ppa && \
    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get -y update && \
    apt-get install -y --no-install-recommends \
      advancecomp \
      apache2-utils \
      autoconf \
      automake \
      bison \
      build-essential \
      bzr \
      cmake \
      curl \
      elixir \
      emacs \
      expect \
      fontconfig \
      fontconfig-config \
      g++ \
      gawk \
      git \
      gifsicle \
      gobject-introspection \
      graphicsmagick \
      graphviz \
      gtk-doc-tools \
      imagemagick \
      jpegoptim \
      libasound2 \
      libexif-dev \
      libffi-dev \
      libfontconfig1 \
      libgconf-2-4 \
      libgd-dev \
      libgdbm-dev \
      libgif-dev \
      libglib2.0-dev \
      libgmp3-dev \
      libgraphicsmagick-q16-3 \
      libgtk-3-0 \
      libgtk2.0-0 \
      libicu-dev \
      libimage-exiftool-perl \
      libjpeg-progs \
      libjpeg-turbo8-dev \
      libmagickwand-dev \
      libmcrypt-dev \
      libncurses5-dev \
      libnss3 \
      libpq-dev \
      libreadline6-dev \
      libsm6 \
      libsqlite3-dev \
      libssl-dev \
      libtiff5-dev \
      libtool \
      libxml2-dev \
      libxrender1 \
      libxslt-dev \
      libxss1 \
      libxtst6 \
      libyaml-dev \
      llvm \
      make \
      mercurial \
      nasm \
      optipng \
      php${PHP_VERSION} \
      php${PHP_VERSION}-xml \
      php${PHP_VERSION}-mbstring \
      php${PHP_VERSION}-gd \
      php${PHP_VERSION}-sqlite3 \
      php${PHP_VERSION}-curl \
      php${PHP_VERSION}-zip \
      pngcrush \
      postgresql \
      postgresql-contrib \
      python3 \
      python3-dev \
      python3-numpy \
      python3-pip \
      python3-setuptools \
      rsync \
      sqlite3 \
      ssh \
      strace \
      swig \
      tree \
      unzip \
      virtualenv \
      wget \
      xvfb \
      zip \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    unset DEBIAN_FRONTEND

RUN locale-gen en_US.UTF-8

################################################################################
#
# Add user for CI runner
#
################################################################################

RUN adduser --system --disabled-password --gecos '' --quiet runner --home /opt/runnerhome
RUN adduser runner sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER runner
ENV PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
ENV PATH "/opt/runnerhome/.local/bin:/opt/runnerhome/.local/lib/python3.7/site-packages:$PATH"

################################################################################
#
# AWS' ElasticBeanstalk CLI
#
################################################################################

USER runner
RUN pip install awsebcli --user

################################################################################
#
# NVM, Node.js & Yarn
#
################################################################################

USER root
RUN curl -o- -L https://yarnpkg.com/install.sh > /usr/local/bin/yarn-installer.sh

USER runner
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
RUN /bin/bash -c "source /opt/runnerhome/.nvm/nvm.sh && \
                  nvm install ${NODE_VERSION} && nvm use ${NODE_VERSION} && npm install -g bower grunt-cli netlify-cli && \
                  bash /usr/local/bin/yarn-installer.sh --version ${YARN_VERSION} && \
                  nvm alias default node && nvm cache clear"

ENV PATH "/opt/runnerhome/.nvm/versions/node/v${NODE_VERSION}/bin:$PATH"
ENV PATH "/opt/runnerhome/.yarn/bin:/opt/runnerhome/.config/yarn/global/node_modules/.bin:$PATH"

################################################################################
#
# Vercel CLI
#
################################################################################

USER root
RUN yarn global add vercel

################################################################################
#
# Serverless CLI
#
################################################################################

USER root
RUN yarn global add serverless

################################################################################
#
# PHP & Composer
#
################################################################################

USER root

RUN update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
    update-alternatives --set phar /usr/bin/phar${PHP_VERSION} && \
    update-alternatives --set phar.phar /usr/bin/phar.phar${PHP_VERSION}

RUN wget -nv https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - | php -- --quiet --version=2.5.8 && \
    mv composer.phar /usr/local/bin/composer

USER runner

RUN mkdir -p /opt/runnerhome/.php
RUN ln -s /usr/bin/php${PHP_VERSION} /opt/runnerhome/.php/php
RUN ln -s /usr/bin/phar${PHP_VERSION} /opt/runnerhome/.php/phar
RUN ln -s /usr/bin/phar.phar${PHP_VERSION} /opt/runnerhome/.php/phar.phar

ENV PATH "/opt/runnerhome/.php:$PATH"

################################################################################
#
# RVM, Ruby & bundler
#
################################################################################

USER runner
RUN command curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
    curl -sL https://get.rvm.io | bash -s stable --with-gems="bundler" --autolibs=4

ENV PATH "/opt/runnerhome/.rvm/bin:$PATH"

RUN /bin/bash -c "source ~/.rvm/scripts/rvm && \
                  rvm install ${RUBY_VERSION_32} && rvm use ${RUBY_VERSION_32} && gem update --system && gem install bundler --force && \
                  rvm use ${RUBY_VERSION_DEFAULT} --default && rvm cleanup all"

ENV PATH "/opt/runnerhome/.rvm/rubies/ruby-${RUBY_VERSION_32}/bin:/usr/local/rvm/gems/ruby-${RUBY_VERSION_32}/bin:$PATH"

################################################################################
#
# Chrome & Firefox
#
################################################################################

USER root
RUN apt-get update
RUN apt-get install -y fonts-liberation libappindicator3-1 xdg-utils

# install Chrome browser
RUN wget -O /usr/src/google-chrome-stable_current_amd64.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && \
  dpkg -i /usr/src/google-chrome-stable_current_amd64.deb ; \
  apt-get install -f -y && \
  rm -f /usr/src/google-chrome-stable_current_amd64.deb
RUN google-chrome --version

# add codecs needed for video playback in firefox
# https://github.com/cypress-io/cypress-docker-images/issues/150
RUN apt-get install mplayer -y

# install Firefox browser
RUN wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && ln -fs /opt/firefox/firefox /usr/bin/firefox

################################################################################
#
# mkcert
#
################################################################################

USER root
RUN \
  apt-get update && apt-get install wget libnss3-tools -y \
  && wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 \
  && chmod +x  mkcert \
  && mv mkcert /usr/local/bin \
  && ./usr/local/bin/mkcert -install

################################################################################
#
# Cleanup
#
################################################################################

USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

################################################################################
#
# Run image as user `runner`
#
################################################################################

USER runner
WORKDIR /opt/runnerhome

CMD ["/bin/bash"]

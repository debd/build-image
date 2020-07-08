################################################################################
#
# General installations & prerequisites
#
################################################################################

FROM jrei/systemd-ubuntu:18.04

ENV PHP_VERSION 7.2
ENV NODE_VERSION 10.15.1
ENV YARN_VERSION 1.17.3
ENV RUBY_VERSION_23 2.3.8
ENV RUBY_VERSION_26 2.6.6
ENV RUBY_VERSION_27 2.7.1
ENV RUBY_VERSION_DEFAULT ${RUBY_VERSION_26}
ENV CHROME_VERSION 80.0.3987.116
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
      emacs25-nox \
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
      openjdk-8-jdk \
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
      python-setuptools \
      python \
      python-dev \
      python-numpy \
      python-pip \
      python3 \
      python3-dev \
      python3-numpy \
      python3-pip \
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
ENV PATH "/opt/runnerhome/.local/bin:/opt/runnerhome/.local/lib/python2.7/site-packages:/opt/runnerhome/.local/lib/python3.6/site-packages:$PATH"

################################################################################
#
# Heroku CLI
#
################################################################################

USER runner
RUN curl https://cli-assets.heroku.com/install-ubuntu.sh | sh

################################################################################
#
# AWS' ElasticBeanstalk CLI
#
################################################################################

USER runner
RUN pip install awsebcli --upgrade --user

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
# PHP & Composer
#
################################################################################

USER root

RUN update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
    update-alternatives --set phar /usr/bin/phar${PHP_VERSION} && \
    update-alternatives --set phar.phar /usr/bin/phar.phar${PHP_VERSION}

RUN wget -nv https://raw.githubusercontent.com/composer/getcomposer.org/cb19f2aa3aeaa2006c0cd69a7ef011eb31463067/web/installer -O - | php -- --quiet && \
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
                  rvm install ${RUBY_VERSION_23} && rvm use ${RUBY_VERSION_23} && gem update --system && gem install bundler --force && \
                  rvm install ${RUBY_VERSION_26} && rvm use ${RUBY_VERSION_26} && gem update --system && gem install bundler --force && \
                  rvm install ${RUBY_VERSION_27} && rvm use ${RUBY_VERSION_27} && gem update --system && gem install bundler --force && \
                  rvm use ${RUBY_VERSION_DEFAULT} --default && rvm cleanup all"

ENV PATH "/opt/runnerhome/.rvm/rubies/ruby-${RUBY_VERSION_23}/bin:/usr/local/rvm/gems/ruby-${RUBY_VERSION_23}/bin:$PATH"
ENV PATH "/opt/runnerhome/.rvm/rubies/ruby-${RUBY_VERSION_26}/bin:/usr/local/rvm/gems/ruby-${RUBY_VERSION_26}/bin:$PATH"
ENV PATH "/opt/runnerhome/.rvm/rubies/ruby-${RUBY_VERSION_27}/bin:/usr/local/rvm/gems/ruby-${RUBY_VERSION_27}/bin:$PATH"

################################################################################
#
# Chrome & Firefox
#
################################################################################

USER root
RUN apt-get update
RUN apt-get install -y fonts-liberation libappindicator3-1 xdg-utils

# install Chrome browser
RUN wget -O /usr/src/google-chrome-stable_current_amd64.deb "http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb" && \
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

CMD ["su", "-", "runner", "-c", "/bin/bash"]

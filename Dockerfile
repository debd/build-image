# Dockerfile used to build base image for projects using Node, Ruby and PHP.
FROM ubuntu:18.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

WORKDIR /code

ENV PHP_VERSION 7.2
ENV RUBY_VERSION_23 2.3.3
ENV RUBY_VERSION_26 2.6.1
ENV NODE_VERSION 10.15.1

ENV NVM_DIR /usr/local/nvm
ENV PATH $NVM_DIR/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

ENV DEBIAN_FRONTEND=noninteractive

# Install base system libraries.
COPY base_dependencies.txt /code/base_dependencies.txt
RUN apt-get update && \
    apt-get install -y $(cat /code/base_dependencies.txt) && \
    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get install -y --no-install-recommends \
      apache2-utils \
      php$PHP_VERSION \
      php$PHP_VERSION-xml \
      php$PHP_VERSION-mbstring \
      php$PHP_VERSION-gd \
      php$PHP_VERSION-sqlite3 \
      php$PHP_VERSION-curl \
      php$PHP_VERSION-zip \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    unset DEBIAN_FRONTEND

# Install nvm and default node version.
RUN mkdir -p $NVM_DIR
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
    echo 'source $NVM_DIR/nvm.sh' >> /etc/profile && \
    /bin/bash -l -c "nvm install $NODE_VERSION;" \
    "nvm alias default $NODE_VERSION;" \
    "nvm use default;"

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g bower
RUN npm install -g grunt-cli
RUN npm install -g netlify-cli

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && \
    apt-get install --yes --no-install-recommends yarn

# Install rvm, default ruby version and bundler.
COPY .gemrc /code/.gemrc
RUN command curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
    curl -L https://get.rvm.io | /bin/bash -s stable && \
    echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
    /bin/bash -l -c "rvm requirements;" && \
    rvm install $RUBY_VERSION_23 && \
    rvm install $RUBY_VERSION_26 && \
    /bin/bash -l -c "rvm use --default $RUBY_VERSION_26 && \
    gem install bundler" && \
    rvm cleanup all

ENV PATH /usr/local/rvm/rubies/ruby-$RUBY_VERSION_26/bin:/usr/local/rvm/gems/ruby-$RUBY_VERSION_26/bin:$PATH
ENV PATH /usr/local/rvm/rubies/ruby-$RUBY_VERSION_23/bin:/usr/local/rvm/gems/ruby-$RUBY_VERSION_23/bin:$PATH

# Install PHP
RUN update-alternatives --set php /usr/bin/php$PHP_VERSION && \
    update-alternatives --set phar /usr/bin/phar$PHP_VERSION && \
    update-alternatives --set phar.phar /usr/bin/phar.phar$PHP_VERSION

RUN wget -nv https://raw.githubusercontent.com/composer/getcomposer.org/cb19f2aa3aeaa2006c0cd69a7ef011eb31463067/web/installer -O - | php -- --quiet && \
    mv composer.phar /usr/local/bin/composer

ENV PATH /usr/bin/php$PHP_VERSION:usr/bin/phar$PHP_VERSION:/usr/bin/phar.phar$PHP_VERSION_$PATH

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

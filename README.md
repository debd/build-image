# build-image

Based on [https://github.com/tzenderman/docker-pyenv-rvm-nvm](https://github.com/tzenderman/docker-pyenv-rvm-nvm) and [https://github.com/netlify/build-image/](https://github.com/netlify/build-image/).

We're using it to build our projects on our own GitLab CI Docker runners.

Can be built (and used) locally with: `docker build --no-cache -t debd/build-image .`

AWS' ElasticBeanstalk CLI can be used like this in a `gitlab-ci.yml` file:

```yml
test:
  stage: test
  script:
    - rm -rf /opt/runnerhome/.aws && mkdir -p /opt/runnerhome/.aws && touch /opt/runnerhome/.aws/config && chmod 600 /opt/runnerhome/.aws/config
    - echo "[profile eb-cli]" >> /opt/runnerhome/.aws/config
    - echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> /opt/runnerhome/.aws/config
    - echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> /opt/runnerhome/.aws/config
```

Additionally, you have to set the following environment vars:

- `AWS_ACCESS_KEY_ID=xxx`
- `AWS_SECRET_ACCESS_KEY=xxx`

Just a note for me (because I always forget this): to push, run ...

- `docker tag debd/build-image debd/build-image:x.x.x`
- `docker push debd/build-image:x.x.x`

## Included software

### Languages

- PHP
  - 7.2
- Ruby
  - 2.6.1 (default)
  - Ruby 2.3.8
- Node
  - 10.15.1
- Python
  - 2.7 (default)
  - 3.6

### Tools

- PHP
  - Composer
- Ruby
  - Bundler 2
- Node
  - Yarn 1.13.0
  - NPM (version corresponding with Node version)
  - `bower`
  - `grunt-cli`
- Python
  - pip (version corresponding with Python version)
- General
  - AWS ElasticBeanstalk CLI
  - Netlify CLI
  - ImageMagick
  - OptiPNG
  - Jpegoptim
  - ... anything inside `Dockerfile` :smile:

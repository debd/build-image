# build-image

Based on [https://github.com/tzenderman/docker-pyenv-rvm-nvm](https://github.com/tzenderman/docker-pyenv-rvm-nvm) and [https://github.com/netlify/build-image/](https://github.com/netlify/build-image/).

We're using it to build our projects on our own GitLab CI Docker runners.

Can be built (and used) locally with: `docker build --no-cache --platform=linux/amd64 -t debd/build-image .`

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

To SSH into the container, run `docker run -it debd/build-image bash`

## Included software

### Languages

- PHP
  - 8.2
- Ruby
  - 3.2.2
- Node
  - 18.16.1
- Python
  - 3.7

### Tools

- Browsers
  - Chrome (latest stable)
  - Firefox 74
- PHP
  - Composer 2.5.8
- Ruby
  - RVM (`source $HOME/.rvm/scripts/rvm` must be included in your CI config)
  - Bundler 1 (2 also available if RVM is sourced)
- Node
  - Yarn 1.22.5
  - NPM (version corresponding with Node version)
  - `bower`
  - `grunt-cli`
- Python
  - pip (version corresponding with Python version)
- General
  - AWS CLI
  - AWS ElasticBeanstalk CLI
  - Netlify CLI
  - Vercel CLI
  - Serverless CLI
  - ImageMagick
  - OptiPNG
  - Jpegoptim
  - mkcert
  - ... anything inside `Dockerfile` :smile:

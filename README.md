# build-image

Based on [https://github.com/tzenderman/docker-pyenv-rvm-nvm](https://github.com/tzenderman/docker-pyenv-rvm-nvm) and [https://github.com/netlify/build-image/](https://github.com/netlify/build-image/).

We're using it to build our projects on our own GitLab CI Docker runners.

Can be built (and used) locally with: `docker build --no-cache -t debd/build-image .`

AWS' ElasticBeanstalk CLI can be used like this in a `gitlab-ci.yml` file:

```yml
test:
  stage: test
  script:
    - rm -rf $HOME/.aws && mkdir -p $HOME/.aws && touch $HOME/.aws/config && chmod 600 $HOME/.aws/config
    - echo "[profile eb-cli]" >> $HOME/.aws/config
    - echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> $HOME/.aws/config
    - echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> $HOME/.aws/config
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
  - 8.0
- Ruby
  - 2.7.2
- Node
  - 14.12.0
- Python
  - 2.7 (via `python` && `pip`)
  - 3.6 (via `python3` && `pip3`)

### Tools

- Browsers
  - Chrome 80
  - Firefox 74
- PHP
  - Composer 2.0.11
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
  - AWS ElasticBeanstalk CLI
  - Netlify CLI
  - Heroku CLI
  - Vercel CLI
  - Serverless CLI
  - ImageMagick
  - OptiPNG
  - Jpegoptim
  - mkcert
  - ... anything inside `Dockerfile` :smile:

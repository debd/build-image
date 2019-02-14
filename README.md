# build-image

Based on [https://github.com/tzenderman/docker-pyenv-rvm-nvm](https://github.com/tzenderman/docker-pyenv-rvm-nvm) and [https://github.com/netlify/build-image/](https://github.com/netlify/build-image/).

We're using it to build our projects on our own GitLab CI Docker runners.

Can be built (and used) locally with: `docker build --no-cache -t debd/build-image .`

To push, run:

- `docker tag debd/build-image debd/build-image:x.x.x`
- `docker push debd/build-image:x.x.x`

## Included software

### Languages

- PHP
  - 7.2
- Ruby
  - 2.6.1 (default)
  - Ruby 2.3.3
- Node
  - 10.15.1

### Tools

- PHP
  - Composer
- Ruby
  - Bundler
- Node
  - Yarn 1.13.0
  - NPM (version corresponding with Node version)
  - `bower`
  - `grunt-cli`
  - `netlify-cli`
- General
  - ImageMagick
  - OptiPNG
  - Jpegoptim
  - ... anything inside `Dockerfile` :smile:

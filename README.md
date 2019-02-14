# build-image

Based on [https://github.com/tzenderman/docker-pyenv-rvm-nvm](https://github.com/tzenderman/docker-pyenv-rvm-nvm).

We're using it to build our projects on our own GitLab CI Docker runners.

This image contains:

- PHP 7.2 & Composer
- RVM, Ruby 2.6.1 and Ruby 2.3.3 (other versions can be installed via `rvm`)
- Node 10.15.1 (other versions can be installed via `nvm`) and Yarn

Can be built (and used) locally with: `docker build --no-cache -t debd/build-image .`

To push, run:

- `docker tag debd/build-image debd/build-image:x.x.x`
- `docker push debd/build-image:x.x.x`

# build-image

Based on [https://github.com/tzenderman/docker-pyenv-rvm-nvm](https://github.com/tzenderman/docker-pyenv-rvm-nvm).

We're using it to build our projects on our own GitLab CI Docker runners.

Can be built (and used) locally with: `docker build --no-cache -t debd/build-image .`

To push, run:

- `docker tag debd/build-image debd/build-image:x.x.x`
- `docker push debd/build-image:x.x.x`

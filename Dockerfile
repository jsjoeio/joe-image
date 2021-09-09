FROM ubuntu:20.04

# Each blue FROM RUN, etc is a step
# and Docker will cache deps at each step

# "Why did I need that again?" The benefit of adding new steps
# along with comments

# "Do we need to add `sh` as a dep?" "No, almost all OS's come with sh which is why you see
# that used more than bash"

# apt-get makes sure it has a local list of all the packages
# gets the lastest list or registry of packages

# DEBIAN_FRONTEND="noninteractive"
# Prevents prompts from popping up during build (we build a Docker image, not install)

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
  # Development utilities
  # You would think they would have these
  # but Ubuntu base image tries to stay as slim as possible
  git \
  bash \
  curl \
  # htop
  # Similar to the performance monitor in Mac
  # might be used under the hood by Coder
  htop \
  # man
  # documentation for things
  # e.g. man curl -> explains how curl works
  man \
  vim \
  ssh \
  # surprised you have to install this
  sudo \
  # operating system info
  lsb-release \
  # allows Coder to talk securely with image over TLS
  ca-certificates \
  # Language support
  locales \
  gnupg \
  jq 

# Install the desired Node.js version into `/usr/local/`
ENV NODE_VERSION=14.17.6
RUN curl \
https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz \
 | tar xzfv - \
  --exclude CHANGELOG.md \
  --exclude LICENSE \
  --exclude README.md \
  --strip-components 1 -C /usr/local/

# Install the Yarn package manager
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

# Add stuff from Joe's install command

# code-server dependencies
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y \
  pkg-config \
  libsecret-1-dev \
  libx11-dev \
  libxkbfile-dev \ 
  python

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y 

# Install Deno
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y unzip
RUN curl -fsSL https://deno.land/x/install/install.sh | sh

# Install Go
# copied from https://github.com/cdr/enterprise-images/blob/main/images/golang/Dockerfile.ubuntu
# Install go1.15
RUN curl -L "https://dl.google.com/go/go1.15.3.linux-amd64.tar.gz" | tar -C /usr/local -xzvf -

# Setup go env vars
ENV GOROOT /usr/local/go
ENV PATH $PATH:$GOROOT/bin

ENV GOPATH /home/coder/go
ENV GOBIN $GOPATH/bin
ENV PATH $PATH:$GOBIN

# Add a user `coder` so that you're not developing as the `root` user
# Makes it feel like "local" laptop experience
RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
USER coder

# Any commands below this run as coder
# Chances are you want to install stuff as root
# so place it above this previous block.

# How to update this image
# 1. Make changes
# 2. Build with: `docker build -t jsjoeio/joe-image .`
# 3. Push to Docker reigstry: `docker push jsjoeio/joe-image`

# Automated Updates on Change
# Two ways to do this
# 1. Connect to DockerHub -> they do it automatically like Vercel
# 2. GitHub Actions (better for a custom or "production" workflow)

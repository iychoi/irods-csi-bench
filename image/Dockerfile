FROM ubuntu:22.04

LABEL maintainer="iychoi@arizona.edu"
ENV GIT_SSL_NO_VERIFY=1

RUN apt-get update && \
      apt-get install --no-install-recommends -y --quiet=2 iozone3 git && \
      rm -rf /var/lib/apt/lists/*


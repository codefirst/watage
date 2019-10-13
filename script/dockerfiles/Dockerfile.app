FROM ruby:2.3.0

RUN apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /work

WORKDIR /work

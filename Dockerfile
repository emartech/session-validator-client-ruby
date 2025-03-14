FROM ruby:3.2-alpine

RUN addgroup -g 1000 ruby && \
    adduser -u 1000 -G ruby -s /bin/sh -D ruby && \
    mkdir /app && \
    chown ruby:ruby /app

RUN apk update && \
    apk upgrade
RUN apk add --virtual .build-deps build-base git

RUN gem update --system && \
    gem update && \
    gem cleanup && \
    gem install bundler

USER ruby
WORKDIR /app

RUN bundle config --local path .bundle

FROM ruby:2.6.5
MAINTAINER David Kirwan <davidkirwanirl@gmail.com>

ENV LIBSODIUM_VERSION 1.0.17

RUN mkdir /app
WORKDIR /app

ADD . /app
RUN bundle install --path /app/bundle/

RUN chmod 755 /app/makerculture.rb
RUN \
    mkdir -p /tmpbuild/libsodium && \
    cd /tmpbuild/libsodium && \
    curl -L https://download.libsodium.org/libsodium/releases/libsodium-${LIBSODIUM_VERSION}.tar.gz -o libsodium-${LIBSODIUM_VERSION}.tar.gz && \
    tar xfvz libsodium-${LIBSODIUM_VERSION}.tar.gz && \
    cd /tmpbuild/libsodium/libsodium-${LIBSODIUM_VERSION}/ && \
    ./configure && \
    make && make check && \
    make install && \
    mv src/libsodium /usr/local/ && \
    rm -Rf /tmpbuild/

ENTRYPOINT ["bundle", "exec", "ruby", "/app/makerculture.rb"]

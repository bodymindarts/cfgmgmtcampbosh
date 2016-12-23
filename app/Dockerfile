FROM alpine:3.4

RUN apk add --update openssl ruby ruby-rdoc ruby-irb ruby-io-console curl \
        && rm -rf /var/cache/apk/*

RUN set -e \
    && curl -sL https://rubygems.org/downloads/rubygems-update-2.6.8.gem -O \
    && gem install rubygems-update-2.6.8.gem --no-ri --no-rdoc \
    && rm -rf rubygems-update-2.6.8.gem \
    && gem install bundler --no-ri --no-rdoc

ADD . /opt/sinatra/
WORKDIR /opt/sinatra

EXPOSE 4567
RUN bundle install

CMD ["bundle", "exec", "ruby", "server.rb"]

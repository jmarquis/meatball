FROM ruby:2.7-alpine

RUN apk add --update \
  less \
  python3 \
  build-base \
  libxml2-dev \
  libxslt-dev \
  && rm -rf /var/cache/apk/*

RUN pip3 install markovify

RUN mkdir -p /opt/meatball
WORKDIR /opt/meatball

COPY Gemfile /opt/meatball
COPY Gemfile.lock /opt/meatball
RUN bundle install

VOLUME /opt/meatball
EXPOSE 4567

CMD ["ruby", "server.rb"]

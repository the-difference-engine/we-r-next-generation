FROM ruby:2.4.4

MAINTAINER Michael Kirlin

RUN apt-get update

RUN mkdir /code
WORKDIR /code
COPY . /code/

RUN bundle install
RUN gem install rerun

ENTRYPOINT ["./docker-entrypoint.sh"]
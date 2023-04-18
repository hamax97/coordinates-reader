# Debian 11
FROM ruby:3.2.0

ARG POSTGRES_USER="coordinates_reader"
ENV POSTGRES_USER=${POSTGRES_USER}

ARG POSTGRES_PASSWORD="CoordinatesReader123*"
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

ARG POSTGRES_HOST="localhost"
ENV POSTGRES_HOST=${POSTGRES_HOST}

ENV RAILS_ENV="production"

# Throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle config set --global deployment 'true'

WORKDIR /usr/src/app

# Install dependencies (non-gems)
COPY bin/install-dependencies-debian11.sh bin/install-dependencies-debian11.sh
RUN bin/install-dependencies-debian11.sh

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bin/run.sh"]

# Development image. Compose mounts the source and runs the Rails dev server.
FROM ruby:3.2-slim

ENV BUNDLE_PATH=/usr/local/bundle \
    RAILS_ENV=development

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 8000
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8000"]

FROM elixir:1.14-slim

RUN mix local.hex --force && \
  mix local.rebar --force

COPY . /usr/src/app
WORKDIR /usr/src/app

ENTRYPOINT /usr/src/app/entrypoint.sh

#/bin/bash

mix deps.get && mix compile

exec "$@"

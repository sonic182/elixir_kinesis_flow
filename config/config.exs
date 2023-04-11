import Config

config :sampleapp, :mongo,
  name: :mongo,
  url: "mongodb://mongo:27017/sample",
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000

import_config "#{Mix.env()}.exs"

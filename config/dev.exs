
import Config

# Connect to local kinesis streams.
# Disable all :ex_aws config blocks in order to connect to remote kinesis streams.
config :ex_aws,
  # region: "us-east-1",
  scheme: "http://",
  host: "localstack",
  port: 80

config :ex_aws, :retries, max_attempts: 1

config :ex_aws, :kinesis,
  scheme: "http://",
  host: "localstack",
  port: 80

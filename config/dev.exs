import Config

# Connect to local kinesis streams.
# Disable all :ex_aws config blocks in order to connect to remote kinesis streams.
config :ex_aws,
  scheme: "http://",
  host: "localstack",
  port: 80,
  access_key_id: ["000000000000", :instance_role],
  secret_access_key: ["000000000000", :instance_role]

config :ex_aws, :retries, max_attempts: 1

config :ex_aws, :kinesis,
  scheme: "http://",
  host: "localstack",
  port: 80

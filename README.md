# Sampleapp

Example app for parsing kinesis stream with elixir and flow, for some real time services.

For better understanding of this demo, you should be familiar with GenServer's and Supervisors (application.ex) to understand how processes are being started.

### How this demo works

* We are using docker and docker-compose
* We use [localstack](https://localstack.cloud/) for emulate kinesis in localhost
* [ex_aws_kinesis](https://github.com/ex-aws/ex_aws_kinesis) library to iteract with local kinesis
* We have added certain demos (IsPrime flow and stages...) for easily understand GenStage and Flow libraries. 


### Using this demo:

You need docker-compose utility.

* Start containers with `docker-compose up -d`
* Enter to app container, to start KinesisDataGenerator, which is a utility module to generate sample search data, and send that data to local kinesis
  * Enter with `docker-compose exec app bash` to app container.
  * An alternative is to run another temporary container, just to ingest data from another machine (other docker container) with `docker-compose run --rm --entrypoint /bin/bash app`
  * Now run a temporal shell with `DEBUG=1 iex -S mix` (the "DEBUG" env var, is to avoid starting kinesis genservers in this test shell)
  * Now, you can run `KinesisDataGenerator.start_link` in this shell and data will start to flow! (It will stop if you close this temporal shell)
* Now you can see app logs with `docker-compose logs -f app` to check what it is being done.
* Also, you can connect to local mongodb, to see what data it is being saved. You can use https://www.mongodb.com/products/compass as a GUI for it.

### How is the data flow in this demo?

* In application.ex file, we have placed the GenStages and Flows required for this demo
  * KinesisReader: it reads every 2 seconds from kinesis and dispatch those events (it ignores consumer's demand, it demands every 2s if any)
  * Broadcaster: producer-consumer that broadcast incoming kinesis data to it's subscribers
  * KinesisParser: transform kinesis data which is binary, to a data structure
  * MongoStore: generic consumer GenStage, that send incoming events to a mongodb collection
  * SearchAggregator: it aggregates and filters search data.


Diagram is like:

```
[kinesis] <-> [KinesisReader] <-> [KinesisParser] <-> [Broadcaster]
                                                             |
                                                             |
                                                       ------------
                                                       |           |
                                                [MongoStore]   [SearchAggregator]
                                                                       |
                                                                  [MongoStore]
```

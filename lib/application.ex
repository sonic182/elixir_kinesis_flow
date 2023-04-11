defmodule Sampleapp.Application do
  @moduledoc false

  use Application

  alias Sampleapp.Flows
  alias Sampleapp.Stages

  @impl Application
  def start(_type, _args) do
    debug = System.get_env("DEBUG")
    mongo_config = Application.get_env(:sampleapp, :mongo)

    children =
      [
        # uncomment this, to see the IsPrime flow running
        # {Flows.IsPrime,
        #  [
        #    [
        #      {Stages.Counter, []}
        #    ],
        #    [
        #      {Stages.IsPrimeFinalStage, []}
        #    ]
        #  ]},
        {Mongo, mongo_config}
      ] ++ add_kinesis(debug)

    opts = [strategy: :one_for_one, name: DooFeeds.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp add_kinesis(nil) do
    kinesis_reader = :kinesis_reader
    broadcaster_id = :kinesis_broadcaster

    [
      {Stages.KinesisReader, [name: kinesis_reader, stream_name: "samplestream"]},
      {Stages.Broadcaster, [name: broadcaster_id]},
      {Flows.KinesisParser, [producers: [kinesis_reader], consumers: [broadcaster_id]]},
      %{
        id: :searches_store,
        start: {Stages.MongoStore, :start_link, [[name: :searches, collection: "searches"]]}
      },
      {Flows.SearchAggregator, [producers: [broadcaster_id], consumers: [:searches]]},
      %{
        id: :rawevents_store,
        start:
          {Stages.MongoStore, :start_link,
           [[name: :rawevents_store, producers: [broadcaster_id], collection: "rawevents"]]}
      }
    ]
  end

  defp add_kinesis(_) do
    []
  end
end

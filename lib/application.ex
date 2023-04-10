defmodule Sampleapp.Application do
  @moduledoc false

  use Application

  alias Sampleapp.Flows
  alias Sampleapp.Stages

  @impl Application
  def start(_type, _args) do
    children = [
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
      {Flows.KinesisParse, [{Stages.KinesisReader, [stream_name: "samplestream"]}]}
    ]

    opts = [strategy: :one_for_one, name: DooFeeds.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

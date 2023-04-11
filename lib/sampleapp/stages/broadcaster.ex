defmodule Sampleapp.Stages.Broadcaster do
  @moduledoc """
  Broadcast data to all consumers, to have different consumers for specific source.
  """

  use GenStage

  require Logger

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenStage.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    Logger.debug("---- broadcaster init... #{inspect(opts)}")

    producer_consumer_opts =
      opts
      |> Keyword.get(:stage_opts, [])
      |> then(&Keyword.merge([dispatcher: GenStage.BroadcastDispatcher], &1))

    {:producer_consumer, opts, producer_consumer_opts}
  end

  def handle_events(events, _from, state) do
    name = Keyword.get(state, :name)
    Logger.debug("[#{name}] broadcasting #{length(events)} events")
    # just a proxy of events
    {:noreply, events, state}
  end
end

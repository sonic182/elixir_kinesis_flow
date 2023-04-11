defmodule Sampleapp.Stages.Broadcaster do
  @moduledoc """
  Broadcast data to all consumers, to have different consumers for specific source.
  """

  use GenStage

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenStage.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    Keyword.merge([dispatcher: GenStage.BroadcastDispatcher], opts)
    {:producer_consumer, opts}
  end

  def handle_events(events, _from, state) do
    # just a proxy of events
    {:noreply, events, state}
  end
end

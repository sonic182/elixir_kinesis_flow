defmodule Sampleapp.Stages.IsPrimeFinalStage do
  @moduledoc """
  Counter Consumer GenStage.

  This is the final step after the Flow counter, in charge of the last part (just logging the current counter)
  """
  require Logger

  use GenStage

  def start_link(counter_flow) do
    GenStage.start_link(__MODULE__, counter_flow)
  end

  def init(counter_flow) do
    opts = []
    {:producer_consumer, counter_flow, opts}
  end

  def handle_events(events, _from, state) do
    # Inspect the events.
    last = events |> Enum.sort(:desc) |> hd() |> Number.Human.number_to_human()
    Logger.info("--- consumer received #{length(events)} events. Last prime calculated: #{last}")

    # Wait for a second.
    Process.sleep(:timer.seconds(3))

    # We are a consumer, so we would never emit items.
    {:noreply, [], state}
  end
end

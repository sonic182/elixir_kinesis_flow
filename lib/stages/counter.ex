defmodule Sampleapp.Stages.Counter do
  @moduledoc """
  Counter GenStage as an example.
  """

  require Logger

  use GenStage

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, 0)
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, counter) when demand > 0 do
    # Logger.debug("received demand of #{demand} items.")

    # If the counter is 3 and we ask for 2 items, we will
    # emit the items 3 and 4, and set the state to 5.
    events = Enum.to_list(counter..(counter + demand - 1))
    {:noreply, events, counter + demand}
  end
end

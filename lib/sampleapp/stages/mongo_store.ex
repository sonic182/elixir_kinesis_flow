defmodule Sampleapp.Stages.MongoStore do
  @moduledoc """
  Generic consumer stage to store incoming data.
  """

  use GenStage

  require Logger

  def start_link(opts) do
    name = Keyword.get(opts, :name)
    GenStage.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    producers = Keyword.get(opts, :producers, [])
    collection = Keyword.get(opts, :collection)
    # min bulk size to store data
    min_bulk = Keyword.get(opts, :min_bulk, 300)
    # max delay to send data
    max_delay = Keyword.get(opts, :max_delay, 5_000)
    buffering = Keyword.get(opts, :buffering, true)

    state = %{
      collection: collection,
      events: :queue.new(),
      events_count: 0,
      min_bulk: min_bulk,
      max_delay: max_delay,
      buffering: buffering
    }

    Logger.debug("--- initialized mongo store with opts #{inspect(opts)}")

    if buffering do
      schedule_foce_insert(max_delay)
    end

    case producers do
      [] ->
        {:consumer, state}

      producers ->
        producers =
          Enum.map(producers, fn pid ->
            {pid, [min_demand: 500, max_demand: 1000]}
          end)

        {:consumer, state, [subscribe_to: producers]}
    end
  end

  def handle_info(:force_insert, state) do
    state = maybe_insert_data(state, true)
    schedule_foce_insert(state.max_delay)

    # no events emit as this is a consumer
    {:noreply, [], state}
  end

  def handle_events(events, _from, %{buffering: false} = state) do
    Logger.debug("received #{length(events)} events to insert on collection #{state.collection}.")

    {:ok, %{acknowledged: true}} = Mongo.insert_many(:mongo, state.collection, events)

    Logger.debug("inserted #{length(events)} events on collection #{state.collection}.")
    {:noreply, [], state}
  end

  def handle_events(events, _from, state) do
    state =
      state
      |> Map.put(:events, :queue.join(state.events, :queue.from_list(events)))
      |> Map.update!(:events_count, fn count -> count + length(events) end)

    state = maybe_insert_data(state)

    # Wait a bit
    # Process.sleep(200)

    # We are a consumer, so we would never emit items.
    {:noreply, [], state}
  end

  defp maybe_insert_data(state, force \\ false) do
    if state.events_count > 0 and (force or state.events_count >= state.min_bulk) do
      events = :queue.to_list(state.events)

      {:ok, %{acknowledged: true}} = Mongo.insert_many(:mongo, state.collection, events)

      Logger.debug("inserted #{state.events_count} events on collection #{state.collection}.")

      state
      |> Map.put(:events, :queue.new())
      |> Map.put(:events_count, 0)
    else
      state
    end
  end

  defp schedule_foce_insert(delay) do
    Process.send_after(self(), :force_insert, delay)
  end
end

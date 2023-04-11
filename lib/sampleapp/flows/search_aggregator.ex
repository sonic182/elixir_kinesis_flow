defmodule Sampleapp.Flows.SearchAggregator do
  @moduledoc """
  Flow in charge of aggregate Kinesis events search data.
  """
  use Flow

  alias Flow.Window

  require Logger

  def start_link(producers: producers, consumers: consumers) do
    Logger.debug(
      "kinesis search aggregator... producers: #{inspect(producers)}, consumers: #{inspect(consumers)}"
    )

    window = get_reducer_window()

    producers
    |> Flow.from_stages(kinesis_spec_opts())
    |> Flow.partition(window: window, key: {:key, :event_key})
    |> Flow.reduce(fn -> %{} end, &reduce_events/2)
    |> Flow.on_trigger(&on_reduce_trigger/3)
    |> Flow.into_stages(consumers)
  end

  defp get_reducer_window() do
    30
    |> Window.fixed(:second, &DateTime.to_unix(&1.timestamp, :millisecond))
    |> Window.allowed_lateness(10, :second)
  end

  defp kinesis_spec_opts() do
    # :stages control the internal flow concurrency
    [stages: 4]
  end

  defp reduce_events(event, acc) do
    user_searches = Map.get(acc, event.event_key, [])
    Map.put(acc, event.event_key, [event | user_searches])
  end

  # on watermark (window checkpoints) just continue with acc
  defp on_reduce_trigger(acc, _, {:fixed, _, :watermark}), do: {[], acc}

  # on when not watermark, process acc
  defp on_reduce_trigger(acc, _, _), do: on_reduce_trigger(acc)

  defp on_reduce_trigger(acc) do
    events = Enum.reduce(acc, [], &cleanup_same_search/2)
    {events, %{}}
  end

  defp cleanup_same_search({_event_key, events}, acc) do
    new_events =
      events
      |> Enum.sort_by(&DateTime.to_unix(&1.timestamp), :desc)
      |> cleanup_same_query()

    acc ++ new_events
  end

  defp cleanup_same_query([current]), do: [current]

  defp cleanup_same_query([current | nexts]) do
    [next | nexts_skip_one] = nexts

    if String.contains?(current.word, next.word) or
         String.jaro_distance(current.word, next.word) > 0.85 do
      cleanup_same_query([current | nexts_skip_one])
    else
      [current | cleanup_same_query(nexts)]
    end
  end
end

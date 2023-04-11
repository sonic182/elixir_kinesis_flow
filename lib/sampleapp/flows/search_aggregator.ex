defmodule Sampleapp.Flows.SearchAggregator do
  @moduledoc """
  Flow in charge of aggregate Kinesis events search data.
  """
  use Flow

  alias Flow.Window
  alias Sampleapp.KinesisEvent

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
    |> Flow.start_link()

    # |> Flow.into_specs(consumers)
  end

  defp get_reducer_window() do
    5
    |> Window.fixed(:second, &DateTime.to_unix(&1.timestamp, :millisecond))
    |> Window.allowed_lateness(3, :second)
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
    IO.inspect(acc, label: "-----acc")
    Process.sleep(1000)
    # events =
    #   acc
    #   |> Enum.map(fn key, searches ->
    #     {key, Enum.sort_by(searches, &DateTime.to_unix(&1.timestamp, :millisecond))}
    #   end)
    {[], %{}}
  end
end

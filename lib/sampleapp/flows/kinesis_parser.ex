defmodule Sampleapp.Flows.KinesisParser do
  @moduledoc """
  Flow in charge of process Kinesis stage.
  """
  use Flow

  alias Flow.Window
  alias Sampleapp.KinesisEvent

  require Logger

  def start_link(producers: producers, consumers: consumers) do
    Logger.debug(
      "kinesis parser... producers: #{inspect(producers)}, consumers: #{inspect(consumers)}"
    )

    producers
    |> Flow.from_stages(flow_specs())
    |> Flow.map(&decode_data/1)
    |> Flow.into_stages(consumers)
  end

  defp flow_specs, do: []

  defp decode_data(item) do
    event =
      item["Data"]
      |> Base.decode64!()
      |> Jason.decode!(keys: :atoms)
      # parse timestamp...
      |> Map.update!(:timestamp, fn ts ->
        {:ok, ts, _offset} = DateTime.from_iso8601(ts)
        ts
      end)
      |> then(&struct(KinesisEvent, &1))

    # special event_key to easily data partition and aggregation
    %KinesisEvent{event | event_key: "#{event.store_id}-#{event.user_id}"}
  end
end

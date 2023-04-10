defmodule Sampleapp.Flows.KinesisParse do
  @moduledoc """
  Flow in charge of process Kinesis stage.
  """
  use Flow

  require Logger

  def start_link(producer_specs) do
    producer_specs
    |> Flow.from_specs(kinesis_spec_opts())
    |> Flow.map(fn item ->
      IO.inspect item, label: "--- item"
    end)
    # |> Flow.through_specs(consumer_specs, counter_producer_consumer_opts())
    |> Flow.start_link()
  end

  defp kinesis_spec_opts() do
    # :stages control the internal flow concurrency
    [min_demand: 10_000, max_demand: 30_000]
  end

end
defmodule Sampleapp.Stages.KinesisReader do
  @moduledoc """
  Kinesis Reader GenStage.
  """

  @delay :timer.seconds(5)

  require Logger

  alias ExAws.Kinesis

  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts)
  end

  def init(opts) do
    stream_name = Keyword.get(opts, :stream_name)

    iterator = get_stream_iterator(stream_name)

    state = %{
      stream_name: stream_name,
      iterator: iterator
    }

    schedule_fetch()
    {:producer, state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  def handle_info(:fetch, state) do
    schedule_fetch()
    {events, iterator} = get_events(state.iterator)
    state = Map.put(state, :iterator, iterator)
    Logger.info("fetched #{length(events)} records")
    {:noreply, events, state}
  end

  defp get_events(iterator, limit \\ 1000) do
    {:ok, %{"NextShardIterator" => iterator, "Records" => records}} =
      Kinesis.get_records(iterator, limit: limit) |> ExAws.request()
    {records, iterator}
  end

  defp schedule_fetch() do
    Process.send_after(self(), :fetch, @delay)
  end

  defp get_stream_iterator(stream_name) do
    {:ok, stream_data} = Kinesis.describe_stream(stream_name) |> ExAws.request()

    shard_id = stream_data["StreamDescription"]["Shards"] |> hd() |> Map.get("ShardId")

    {:ok, %{"ShardIterator" => iterator}} =
      stream_name |> Kinesis.get_shard_iterator(shard_id, :latest) |> ExAws.request()

    iterator
  end
end

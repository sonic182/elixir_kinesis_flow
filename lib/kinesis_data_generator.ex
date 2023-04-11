defmodule KinesisDataGenerator do
  @moduledoc """
  Sample data generator, for kinesis stream.
  """

  require Logger

  @search_words [
    "iphone",
    "ssd kingstong",
    "eyeliner",
    "shampoo",
    "amd ryzen",
    "pendrive",
    "guitarra",
    "monitor",
    "hp deskjet",
    "conga",
    "patinete electrico",
    "microondas"
  ]

  @buffer_size_limit 1000

  # from 400 to 700 ms delay to send records to buffer
  @sleep_delay {400, 700}

  alias ExAws.Kinesis

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    users_num = Keyword.get(opts, :users, 1000)
    stores_num = Keyword.get(opts, :stores, 10)

    stores_ids = generate_stores(stores_num)
    spawn_users(stores_ids, users_num)

    state = %{
      stream: "samplestream",
      buffer: :queue.new(),
      buffer_size: 0
    }

    {:ok, state}
  end

  def handle_info({:search, word, user_id, store_id, timestamp}, state) do
    record =
      to_kinesis(%{
        word: word,
        store_id: store_id,
        user_id: user_id,
        timestamp: timestamp |> DateTime.to_iso8601()
      })

    if state.buffer_size + 1 >= @buffer_size_limit do
      # correct buffer order
      records = :queue.to_list(state.buffer)
      Logger.info("sending #{state.buffer_size + 1} records")
      {:ok, _} = state.stream |> Kinesis.put_records(records) |> ExAws.request()

      state =
        state
        |> Map.put(:buffer, :queue.new())
        |> Map.put(:buffer_size, 0)

      {:noreply, state}
    else
      buffer = :queue.in(record, state.buffer)

      state =
        state
        |> Map.put(:buffer, buffer)
        |> Map.put(:buffer_size, state.buffer_size + 1)

      {:noreply, state}
    end
  end

  defp generate_stores(store_num) do
    1..store_num
    |> Enum.map(fn _num ->
      random_id(10)
    end)
  end

  defp spawn_users(stores_ids, users_num) do
    buffer_pid = self()

    1..users_num
    |> Enum.each(fn _num ->
      random_store = Enum.random(stores_ids)
      user_id = random_id(6)
      Task.start_link(__MODULE__, :user_searcher, [buffer_pid, user_id, random_store])
    end)
  end

  def user_searcher(buffer_pid, user_id, store_id) do
    # do a sample search...
    random_word = Enum.random(@search_words)
    search_words = get_search_words(random_word, String.length(random_word))

    Enum.each(search_words, fn word ->
      # send data to  process buffer
      send(buffer_pid, {:search, word, user_id, store_id, DateTime.utc_now()})
      Process.sleep(get_delay())
    end)

    # wait a bit until search again
    Process.sleep(:timer.seconds(10))
    user_searcher(buffer_pid, user_id, store_id)
  end

  # from a search word like "offer" it generates ["off", "offe", "offer"]
  defp get_search_words(random_word, length, pos \\ 0)

  defp get_search_words(_random_word, length, pos) when length == pos, do: []

  defp get_search_words(random_word, length, pos) when pos == 0 do
    slice = String.slice(random_word, 0, 3)

    [slice | get_search_words(random_word, length, 3)]
  end

  defp get_search_words(random_word, length, pos) do
    slice = String.slice(random_word, 0, pos + 1)

    [slice | get_search_words(random_word, length, pos + 1)]
  end

  # set record to kinesis format.
  defp to_kinesis(record) do
    %{
      data: Jason.encode!(record),
      partition_key: record.store_id
    }
  end

  # random delay between min and max values
  defp get_delay() do
    {min, max} = @sleep_delay
    diff = max - min
    min + :rand.uniform(diff)
  end

  defp random_id(bytes_num), do: :crypto.strong_rand_bytes(bytes_num) |> Base.encode16()
end

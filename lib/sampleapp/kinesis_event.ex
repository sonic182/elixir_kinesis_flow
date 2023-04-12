defmodule Sampleapp.KinesisEvent do
  @moduledoc """
  Kinesis Event struct.

  %KinesisEvent{
    store_id: "FAE32CDA",
    user_id: "GAE42ACE",
    timestamp: ~U[2023-04-12 14:34:45.878687Z],
    word: "camisa",
    event_key: "FAE32CDA-GAE42ACE"
  }
  """
  @enforce_keys [:store_id, :timestamp, :user_id, :word]
  defstruct [:store_id, :timestamp, :user_id, :word, :event_key]
end



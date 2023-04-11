defmodule Sampleapp.KinesisEvent do
  @moduledoc """
  Kinesis Event struct.
  """
  @enforce_keys [:store_id, :timestamp, :user_id, :word]
  defstruct [:store_id, :timestamp, :user_id, :word, :event_key]
end

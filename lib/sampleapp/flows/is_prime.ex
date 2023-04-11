defmodule Sampleapp.Flows.IsPrime do
  @moduledoc """
  Flow in charge of process counter producer
  """
  use Flow

  require Logger

  def start_link([producer_specs, consumer_specs]) do
    producer_specs
    |> Flow.from_specs(counter_opts())
    |> Flow.filter(&is_prime/1)
    |> Flow.through_specs(consumer_specs, counter_producer_consumer_opts())
    |> Flow.start_link()
  end

  defp counter_opts() do
    # :stages control the internal flow concurrency
    [min_demand: 10_000, max_demand: 30_000]
  end

  defp counter_producer_consumer_opts() do
    []
  end

  # function to check if a number is prime or not (obtained with chatgpt)
  defp is_prime(n) when n < 2, do: false
  defp is_prime(2), do: true
  defp is_prime(n) when rem(n, 2) == 0, do: false

  defp is_prime(n) do
    is_prime_helper(n, trunc(:math.sqrt(n)))
  end

  defp is_prime_helper(_, 1), do: true
  defp is_prime_helper(n, m) when rem(n, m) == 0, do: false

  defp is_prime_helper(n, m) do
    is_prime_helper(n, m - 1)
  end
end

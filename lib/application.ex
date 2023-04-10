defmodule Sampleapp.Application do
  @moduledoc false

  use Application

  alias Sampleapp.Flows
  alias Sampleapp.Stages

  @impl Application
  def start(_type, _args) do
    children = [
      {Flows.IsPrime, [counter_specs(), is_prime_result_stage()]}
    ]

    opts = [strategy: :one_for_one, name: DooFeeds.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp counter_specs() do
    [
      {Stages.Counter, []}
    ]
  end

  defp is_prime_result_stage() do
    [
      {Stages.IsPrimeFinalStage, []}
    ]
  end
end

defmodule Sampleapp.Application do
  @moduledoc false

  use Application

  alias Sampleapp.Flows
  alias Sampleapp.Stages

  @impl Application
  def start(_type, _args) do
    children = [
      # uncomment this, to see the IsPrime flow running
      # {Flows.IsPrime, [counter_specs(), is_prime_result_stage()]},
      # {Flows.KinesisParse, counter_specs()}
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

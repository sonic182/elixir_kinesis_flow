defmodule Sampleapp.MixProject do
  use Mix.Project

  def project do
    [
      app: :sampleapp,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Sampleapp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_aws, "~> 2.0"},
      {:ex_aws_kinesis, "~> 2.0"},
      {:flow, "~> 1.2"},
      {:hackney, "~> 1.9"},
      {:jason, "~> 1.4"},
      {:number, "~> 1.0"},
      {:poison, "~> 3.0"}
    ]
  end
end

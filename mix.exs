defmodule Rocket.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rocket,
      version: "0.1.0",
      elixir: "~> 1.18",
      description: description(),
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      package: package(),
      test_coverage: [summary: [threshold: 90]],
      preferred_cli_env: [
        credo: :test,
        "test.coverage": :test
      ],
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {Rocket.Application, []}]
  end

  defp description do
    """
    A Firebase Cloud Messaging HTTP v1 client for Elixir.
    """
  end

  defp deps do
    [
      {:gen_stage, "~> 1.0"},
      {:finch, "~> 0.16 or ~> 0.22", optional: true},
      {:goth, "~> 1.4"},
      {:jason, "~> 1.4"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.36", only: :dev, runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.2", only: :dev, runtime: false},
      {:mox, "~> 1.2", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"],
      maintainers: ["Tom Pesman"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/9to5/rocket",
        "Docs" => "https://hexdocs.pm/rocket"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/9to5/rocket",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end
end

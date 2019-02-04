defmodule Rocket.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rocket,
      version: "0.0.1",
      elixir: "~> 1.5",
      description: description(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  def application do
    [extra_applications: [:logger, :retry], mod: {Rocket.Application, []}]
  end

  defp description do
    """
    A Firebase Cloud Message HTTP v1 client for Elixir
    """
  end

  defp deps do
    [
      {:httpoison, "~> 1.5"},
      {:jason, "~> 1.1"},
      {:retry, "~> 0.10.0"},
      {:mix_test_watch, "~> 0.9", only: :dev, runtime: false},
      {:goth, "~> 1.0"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Tom Pesman"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/9to5/rocket",
        "Docs" => "https://hexdocs.pm/rocket"
      }
    ]
  end
end

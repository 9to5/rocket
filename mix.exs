defmodule Rocket.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rocket,
      version: "0.0.1",
      elixir: "~> 1.18",
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
        "coveralls.post": :test,
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
    [extra_applications: [:logger], mod: {Rocket.Application, []}]
  end

  defp description do
    """
    A Firebase Cloud Message HTTP v1 client for Elixir
    """
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:exvcr, "~> 0.13", only: :test},
      {:gen_stage, "~> 1.0"},
      {:goth, "~> 1.0"},
      {:finch, "~> 0.16"},
      {:jason, "~> 1.1"},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false}
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

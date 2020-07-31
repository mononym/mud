defmodule EctoEnum.Mixfile do
  use Mix.Project

  @version "1.4.0"

  def project do
    [
      app: :ecto_enum,
      version: @version,
      elixir: "~> 1.2",
      deps: deps(),
      description: "Ecto extension to support enums in models",
      test_paths: test_paths(Mix.env()),
      package: package(),
      name: "EctoEnum",
      docs: [source_ref: "v#{@version}", source_url: "https://github.com/gjaldon/ecto_enum"]
    ]
  end

  defp test_paths(:mysql), do: ["test/mysql"]
  defp test_paths(_), do: ["test/pg"]

  defp package do
    [
      maintainers: ["Gabriel Jaldon"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/gjaldon/ecto_enum"},
      files: ~w(mix.exs README.md CHANGELOG.md lib .formatter.exs)
    ]
  end

  def application do
    [applications: [:logger, :ecto, :ecto_sql]]
  end

  defp deps do
    [
      {:ecto, ">= 3.0.0"},
      {:ecto_sql, "> 3.0.0"},
      {:postgrex, ">= 0.0.0", optional: true},
      {:mariaex, ">= 0.0.0", optional: true},
      {:ex_doc, "~> 0.19", only: [:docs, :dev]},
      {:earmark, "~> 1.2", only: [:docs, :dev]},
      {:inch_ex, ">= 0.0.0", only: [:dev, :test]}
    ]
  end
end

defmodule Pp.MixProject do
  use Mix.Project

  def project do
    [
      app: :pp,
      version: "0.1.1",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Pretty printing for Elixir",
      name: "PP",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Juan Wajnerman"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/waj/ex_pp"}
    ]
  end
end

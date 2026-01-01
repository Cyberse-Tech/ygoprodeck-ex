defmodule YGOProDeck.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/Cyberse-Tech/ygoprodeck-ex"

  def project do
    [
      app: :ygoprodeck,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      name: "YGOProDeck",
      description: "Elixir client for the YGOPRODECK Yu-Gi-Oh! card database API"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:finch, "~> 0.18", optional: true},
      {:req, "~> 0.5", optional: true},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:bypass, "~> 2.1", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end

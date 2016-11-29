defmodule Ectoplasm.Mixfile do
  use Mix.Project

  def project do
    [app: :ectoplasm,
     description: "A collection of factories and helpers for testing ecto schemas",
     package: package(),
     licenses: ["MIT"],
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ecto, ">= 2.0.0"},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [licenses: ["MIT"],
     maintainers: ["cjpoll@gmail.com"],
     links: %{"Github" => "http://github.com/cjpoll/ectoplasm"}]
  end
end

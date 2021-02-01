defmodule UeberauthTonies.MixProject do
  use Mix.Project

  @url "https://github.com/benvp/ueberauth_tonies"

  def project do
    [
      app: :ueberauth_tonies,
      version: "0.1.0",
      description: "Ueberauth strategy for Tonies.",
      source_url: @url,
      homepage_url: @url,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauth2, "~> 2.0"},
      {:ueberauth, "~> 0.6"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Benjamin von Polheim"],
      licenses: ["MIT"],
      links: %{GitHub: @url}
    ]
  end
end

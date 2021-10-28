defmodule TelemetryWrappers.MixProject do
  use Mix.Project

  def project do
    [
      app: :telemetry_wrappers,
      version: "1.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      docs: [extras: ["README.md"], main: "readme"],
      deps: deps(),
      package: package(),
      description: description()
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
      {:telemetry, "~> 1.0"},
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.20", only: [:dev, :test]},
      {:telemetry_poller, "~> 1.0", only: [:test]}
    ]
  end

  defp description do
    "Small wrappers to enhance usage of the telemetry library."
  end

  defp package do
    [
      name: "telemetry_wrappers",
      files: ["lib/*", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Pawel Antemijczuk"],
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/haljin/telemetry_wrappers"}
    ]
  end
end

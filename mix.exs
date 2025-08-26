defmodule MagicaX.MixProject do
  use Mix.Project

  def project do
    [
      app: :magicax,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "MagicaX",
      source_url: "https://github.com/lalabuy948/magicax",
      homepage_url: "https://github.com/lalabuy948/magicax",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.38", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A comprehensive Elixir toolkit for parsing and generating MagicaVoxel (.vox) files.
    Features 100% data coverage for parsing and flexible generation workflows including
    JSON-to-VOX conversion and programmatic creation.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lalabuy948/magicax"},
      maintainers: ["lalabuy948"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CLAUDE.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md"
      ],
      groups_for_extras: [
        Guide: ["README.md"]
      ],
      groups_for_modules: [
        Core: [MagicaX],
        Parser: [MagicaX.VoxParser],
        Generator: [MagicaX.VoxGenerator]
      ],
      source_ref: "v0.1.0",
      source_url: "https://github.com/lalabuy948/magicax",
      formatters: ["html"],
      authors: ["lalabuy948"]
    ]
  end
end

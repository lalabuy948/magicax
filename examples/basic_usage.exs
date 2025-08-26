#!/usr/bin/env elixir

Mix.install([
  {:magicax, path: "../", force: true}
])

defmodule BasicUsage do
  @moduledoc """
  Basic usage examples showing the main MagicaX functionality.
  """

  def run do
    IO.puts("=== MagicaX Basic Usage Examples ===")
    IO.puts("")

    # Example 1: Parse an existing VOX file
    parse_example()

    IO.puts("")

    # Example 2: Generate a simple VOX file programmatically
    generate_programmatically()

    IO.puts("")

    # Example 3: Create and parse a roundtrip
    roundtrip_example()

    IO.puts("\n✅ All basic usage examples completed!")
  end

  defp parse_example do
    IO.puts("📖 Example 1: Parsing a VOX file")

    vox_file = "../vox/teapot.vox"

    if File.exists?(vox_file) do
      case MagicaX.VoxParser.parse_vox_file(vox_file) do
        {:ok, data} ->
          IO.puts("✅ Successfully parsed #{vox_file}")
          IO.puts("   Dimensions: #{inspect(data.size)}")
          IO.puts("   Voxels: #{length(data.voxels)}")
          IO.puts("   Has palette: #{data.palette != nil}")
          IO.puts("   Materials: #{length(data.materials)}")
          IO.puts("   Layers: #{length(data.layers)}")

        {:error, reason} ->
          IO.puts("❌ Failed to parse: #{reason}")
      end
    else
      IO.puts("⚠️  Sample file not found: #{vox_file}")
    end
  end

  defp generate_programmatically do
    IO.puts("🔧 Example 2: Generate VOX file programmatically")

    # Define a simple 3x3x3 model with some voxels
    dimensions = {5, 5, 5}

    # Create a simple cross pattern
    voxels = [
      # Center vertical line
      {2, 2, 0, 1},
      {2, 2, 1, 1},
      {2, 2, 2, 1},
      {2, 2, 3, 1},
      {2, 2, 4, 1},

      # Horizontal line at middle height
      {0, 2, 2, 2},
      {1, 2, 2, 2},
      {3, 2, 2, 2},
      {4, 2, 2, 2},

      # Cross on another plane
      {2, 0, 2, 3},
      {2, 1, 2, 3},
      {2, 3, 2, 3},
      {2, 4, 2, 3}
    ]

    # Custom palette with just a few colors
    custom_palette = [
      # Red
      {255, 0, 0, 255},
      # Green
      {0, 255, 0, 255},
      # Blue
      {0, 0, 255, 255},
      # Yellow
      {255, 255, 0, 255}
    ]

    # Pad palette to 256 colors
    padded_palette =
      custom_palette ++
        Enum.map(1..252, fn _ -> {128, 128, 128, 255} end)

    case MagicaX.VoxGenerator.generate_vox_file(
           "basic_cross.vox",
           dimensions,
           voxels,
           padded_palette
         ) do
      {:ok, message} ->
        IO.puts("✅ #{message}")

      {:error, reason} ->
        IO.puts("❌ Error generating file: #{reason}")
    end
  end

  defp roundtrip_example do
    IO.puts("🔄 Example 3: Roundtrip test (generate -> parse)")

    # First, generate a simple cube
    case MagicaX.VoxGenerator.generate_cube("roundtrip_cube.vox", 4) do
      {:ok, _message} ->
        IO.puts("✅ Generated test cube")

        # Now parse it back
        case MagicaX.VoxParser.parse_vox_file("roundtrip_cube.vox") do
          {:ok, data} ->
            IO.puts("✅ Successfully parsed generated file")
            IO.puts("   Roundtrip dimensions: #{inspect(data.size)}")
            IO.puts("   Roundtrip voxels: #{length(data.voxels)}")
            IO.puts("   Roundtrip palette: #{data.palette != nil}")

            # Verify the cube structure
            {x, y, z} = data.size

            if x == 4 and y == 4 and z == 4 do
              IO.puts("✅ Dimensions match expected cube size")
            else
              IO.puts("⚠️  Unexpected dimensions")
            end

          {:error, reason} ->
            IO.puts("❌ Failed to parse generated file: #{reason}")
        end

      {:error, reason} ->
        IO.puts("❌ Error generating cube: #{reason}")
    end
  end
end

# Run the example
BasicUsage.run()

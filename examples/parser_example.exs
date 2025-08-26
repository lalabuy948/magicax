#!/usr/bin/env elixir

Mix.install([
  {:magicax, path: "../", force: true}
])

defmodule ParserExample do
  @moduledoc """
  Example usage of MagicaX.VoxParser for parsing VOX files.
  """

  def run do
    IO.puts("=== MagicaX VOX Parser Example ===")

    # Get file from command line or use default
    file_to_parse =
      case System.argv() do
        [] -> "../vox/teapot.vox"
        [file] -> file
      end

    IO.puts("Parsing file: #{file_to_parse}")

    # Parse the VOX file
    case MagicaX.VoxParser.parse_vox_file(file_to_parse) do
      {:ok, data} ->
        display_parse_results(data, file_to_parse)

      {:error, reason} ->
        IO.puts("❌ Error: #{reason}")
        System.halt(1)
    end
  end

  defp display_parse_results(data, filename) do
    IO.puts("✅ Parsed #{filename} successfully:")
    IO.puts("")

    # Basic information
    IO.inspect(data.size, label: "Model Size (x, y, z)")
    IO.inspect(length(data.voxels), label: "Number of Voxels")
    IO.inspect(Enum.take(data.voxels, 5), label: "First 5 Voxels (x, y, z, color_index)")

    # Palette information
    if data.palette do
      IO.inspect(length(data.palette), label: "Palette Colors")
      IO.inspect(Enum.take(data.palette, 5), label: "First 5 Palette Colors (r, g, b, a)")
    else
      IO.puts("Palette: Not found")
    end

    # Extended data
    IO.inspect(length(data.materials), label: "Number of Materials")

    if length(data.materials) > 0 do
      IO.inspect(Enum.take(data.materials, 3), label: "First 3 Materials")
    end

    IO.inspect(length(data.layers), label: "Number of Layers")

    if length(data.layers) > 0 do
      IO.inspect(Enum.take(data.layers, 3), label: "First 3 Layers")
    end

    IO.inspect(length(data.objects), label: "Number of Objects")
    IO.inspect(length(data.cameras), label: "Number of Cameras")
    IO.inspect(length(data.notes), label: "Number of Notes")
    IO.inspect(length(data.transforms), label: "Number of Transforms")
    IO.inspect(length(data.shapes), label: "Number of Shapes")
    IO.inspect(length(data.groups), label: "Number of Groups")

    # Metadata
    if data.metadata do
      IO.inspect(data.metadata, label: "File Metadata")
    end

    # Matrix information
    if data.matrix do
      IO.puts("✅ 3D Matrix generated successfully")

      IO.puts(
        "Matrix dimensions: #{map_size(data.matrix)} x #{map_size(data.matrix[0] || %{})} x #{map_size(data.matrix[0][0] || %{})}"
      )
    else
      IO.puts("⚠️  No 3D matrix generated")
    end

    # Chunk analysis
    IO.inspect(data.skipped_chunks, label: "Skipped Chunks")
    IO.inspect(data.skipped_bytes, label: "Skipped Bytes")

    if map_size(data.chunk_analysis) > 0 do
      IO.puts("\n=== CHUNK ANALYSIS ===")

      data.chunk_analysis
      |> Enum.sort_by(fn {_type, info} -> info.total_bytes end, :desc)
      |> Enum.each(fn {chunk_type, info} ->
        IO.puts(
          "#{chunk_type}: #{info.count} chunks, #{info.total_bytes} bytes total, #{info.avg_size} bytes avg"
        )
      end)
    else
      IO.puts("No chunks were skipped")
    end

    IO.puts("\n💡 Usage: elixir examples/parser_example.exs [vox_file]")
  end
end

# Run the example
ParserExample.run()

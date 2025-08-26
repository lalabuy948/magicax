#!/usr/bin/env elixir

Mix.install([
  {:magicax, path: "../", force: true}
])

defmodule GeneratorExample do
  @moduledoc """
  Example usage of MagicaX.VoxGenerator for creating VOX files.
  """

  def run do
    IO.puts("=== MagicaX VOX Generator Example ===")

    case System.argv() do
      [json_file] ->
        generate_from_json_file(json_file)

      [json_file, output_file] ->
        generate_from_json_file(json_file, output_file)

      _ ->
        run_all_examples()
    end
  end

  defp generate_from_json_file(json_file, output_file \\ nil) do
    IO.puts("🚀 Generating VOX file from: #{json_file}")

    case MagicaX.VoxGenerator.generate_from_json_file(json_file, output_file) do
      {:ok, message} ->
        IO.puts("✅ #{message}")

      {:error, reason} ->
        IO.puts("❌ Error: #{reason}")
        System.halt(1)
    end
  end

  defp run_all_examples do
    IO.puts("📁 No JSON file specified. Running all examples...")

    # Example 1: Generate basic shapes
    generate_basic_shapes()

    # Example 2: Generate from JSON string
    generate_from_json_string()

    # Example 3: Generate from map
    generate_from_map()

    # Example 4: Generate recursive fractal (showcases programmatic creation)
    generate_recursive_fractal()

    # Example 5: Test JSON examples from json folder
    test_json_examples()

    IO.puts("\n💡 Usage: elixir examples/generator_example.exs [json_file] [output_file]")
  end

  defp generate_basic_shapes do
    IO.puts("\n🎯 Generating basic shapes...")

    # Generate a test cube
    IO.puts("Generating test cube...")

    case MagicaX.VoxGenerator.generate_cube("examples_cube.vox", 8) do
      {:ok, message} -> IO.puts("✅ #{message}")
      {:error, reason} -> IO.puts("❌ Error: #{reason}")
    end

    # Generate a test sphere
    IO.puts("Generating test sphere...")

    case MagicaX.VoxGenerator.generate_sphere("examples_sphere.vox", 6) do
      {:ok, message} -> IO.puts("✅ #{message}")
      {:error, reason} -> IO.puts("❌ Error: #{reason}")
    end

    # Generate a teapot
    IO.puts("Generating teapot...")

    case MagicaX.VoxGenerator.generate_teapot("examples_teapot.vox", 0.5) do
      {:ok, message} -> IO.puts("✅ #{message}")
      {:error, reason} -> IO.puts("❌ Error: #{reason}")
    end
  end

  defp generate_from_json_string do
    IO.puts("\n📝 Generating from JSON string...")

    example_json = """
    {
      "dimensions": [5, 5, 5],
      "voxels": [
        {"x": 0, "y": 0, "z": 0, "color_index": 1},
        {"x": 1, "y": 0, "z": 0, "color_index": 2},
        {"x": 2, "y": 0, "z": 0, "color_index": 3},
        {"x": 0, "y": 1, "z": 0, "color_index": 4},
        {"x": 1, "y": 1, "z": 0, "color_index": 5},
        {"x": 2, "y": 1, "z": 0, "color_index": 6}
      ],
      "palette": [
        {"r": 255, "g": 0, "b": 0, "a": 255},
        {"r": 0, "g": 255, "b": 0, "a": 255},
        {"r": 0, "g": 0, "b": 255, "a": 255},
        {"r": 255, "g": 255, "b": 0, "a": 255},
        {"r": 255, "g": 0, "b": 255, "a": 255},
        {"r": 0, "g": 255, "b": 255, "a": 255}
      ]
    }
    """

    case MagicaX.VoxGenerator.generate_from_json("examples_json.vox", example_json) do
      {:ok, message} -> IO.puts("✅ #{message}")
      {:error, reason} -> IO.puts("❌ Error: #{reason}")
    end
  end

  defp generate_from_map do
    IO.puts("\n🗺️  Generating from map...")

    example_map = %{
      "dimensions" => [3, 3, 3],
      "voxels" => [
        %{"x" => 0, "y" => 0, "z" => 0, "color_index" => 1},
        %{"x" => 1, "y" => 1, "z" => 1, "color_index" => 2},
        %{"x" => 2, "y" => 2, "z" => 2, "color_index" => 3}
      ],
      "palette" => [
        %{"r" => 255, "g" => 0, "b" => 0, "a" => 255},
        %{"r" => 0, "g" => 255, "b" => 0, "a" => 255},
        %{"r" => 0, "g" => 0, "b" => 255, "a" => 255}
      ]
    }

    case MagicaX.VoxGenerator.generate_from_map("examples_map.vox", example_map) do
      {:ok, message} -> IO.puts("✅ #{message}")
      {:error, reason} -> IO.puts("❌ Error: #{reason}")
    end
  end

  defp generate_recursive_fractal do
    IO.puts("\n🌳 Generating recursive fractal tree (showcases programmatic creation)...")

    # Create a 3D Sierpinski pyramid using recursion
    dimensions = {32, 32, 32}

    # Generate the fractal recursively
    voxels = generate_sierpinski_pyramid({16, 16, 0}, 8, 4, 1)

    IO.puts("   Generated #{length(voxels)} voxels recursively")

    # Create custom palette with gradient colors
    gradient_palette = create_gradient_palette()

    case MagicaX.VoxGenerator.generate_vox_file(
           "examples_fractal.vox",
           dimensions,
           voxels,
           gradient_palette
         ) do
      {:ok, message} -> IO.puts("✅ #{message}")
      {:error, reason} -> IO.puts("❌ Error: #{reason}")
    end
  end

  # Recursive function to generate a 3D Sierpinski pyramid
  defp generate_sierpinski_pyramid(_, _, 0, _), do: []

  defp generate_sierpinski_pyramid({x, y, z}, size, depth, color_base) do
    half_size = div(size, 2)

    # Base case: generate a small tetrahedron
    if depth <= 1 do
      generate_tetrahedron({x, y, z}, size, color_base)
    else
      # Recursive case: generate 4 smaller pyramids at the corners
      # Cycle through colors
      color = rem(color_base + depth, 16) + 1

      corners = [
        # Bottom front left
        {x, y, z},
        # Bottom front right
        {x + half_size, y, z},
        # Bottom back center
        {x + quarter(size), y + half_size, z},
        # Top center
        {x + quarter(size), y + quarter(size), z + half_size}
      ]

      Enum.flat_map(corners, fn corner ->
        generate_sierpinski_pyramid(corner, half_size, depth - 1, color + 1)
      end)
    end
  end

  # Generate a small tetrahedron (4-sided pyramid)
  defp generate_tetrahedron({cx, cy, cz}, size, color) do
    for x <- 0..(size - 1),
        y <- 0..(size - 1),
        z <- 0..(size - 1),
        # Only include voxels that form a rough tetrahedron shape
        x + y + z <= size * 1.5,
        x >= 0,
        y >= 0,
        z >= 0,
        cx + x < 32,
        cy + y < 32,
        cz + z < 32 do
      {cx + x, cy + y, cz + z, color}
    end
  end

  # Helper function to get quarter of a number
  defp quarter(n), do: div(n, 4)

  # Create a gradient palette for the fractal
  defp create_gradient_palette do
    # Create a rainbow gradient
    base_colors =
      for i <- 0..15 do
        hue = i * 360 / 16
        {r, g, b} = hsv_to_rgb(hue, 1.0, 1.0)
        {trunc(r), trunc(g), trunc(b), 255}
      end

    # Fill remaining slots with variations
    remaining = for _ <- 16..255, do: {128, 128, 128, 255}

    base_colors ++ remaining
  end

  # Convert HSV to RGB (simplified version)
  defp hsv_to_rgb(h, s, v) do
    c = v * s
    h_sector = h / 60
    x = c * (1 - abs(:math.fmod(h_sector, 2) - 1))
    m = v - c

    {r_prime, g_prime, b_prime} =
      cond do
        h < 60 -> {c, x, 0}
        h < 120 -> {x, c, 0}
        h < 180 -> {0, c, x}
        h < 240 -> {0, x, c}
        h < 300 -> {x, 0, c}
        true -> {c, 0, x}
      end

    {(r_prime + m) * 255, (g_prime + m) * 255, (b_prime + m) * 255}
  end

  defp test_json_examples do
    IO.puts("\n🧪 Testing JSON examples from json/ folder...")

    json_examples = [
      "json/01_simple_cube.json",
      "json/02_colorful_pyramid.json",
      "json/03_house.json",
      "json/04_landscape.json",
      "json/05_complex_scene.json"
    ]

    Enum.each(json_examples, fn json_file ->
      if File.exists?(json_file) do
        IO.puts("Testing: #{json_file}")

        # Generate with modified filename to avoid conflicts
        base_name = Path.basename(json_file, ".json")
        output_file = "examples_#{base_name}.vox"

        case MagicaX.VoxGenerator.generate_from_json_file(json_file, output_file) do
          {:ok, message} -> IO.puts("✅ #{message}")
          {:error, reason} -> IO.puts("❌ Error: #{reason}")
        end
      else
        IO.puts("⚠️  File not found: #{json_file}")
      end
    end)
  end
end

# Run the example
GeneratorExample.run()

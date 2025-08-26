defmodule MagicaX.VoxGenerator do
  @moduledoc """
  A flexible VOX file generator for MagicaVoxel format.
  
  Supports multiple input methods:
  - Direct programmatic generation
  - JSON-to-VOX conversion with comprehensive validation
  - Built-in shape generators (cube, sphere, teapot)
  - Custom palette support with 256-color capability
  
  ## Examples
  
      # Generate from JSON file
      {:ok, message} = MagicaX.VoxGenerator.generate_from_json_file("model.json")
      
      # Generate programmatically
      dimensions = {10, 10, 10}
      voxels = [{0, 0, 0, 1}, {1, 1, 1, 2}]
      {:ok, message} = MagicaX.VoxGenerator.generate_vox_file("model.vox", dimensions, voxels)
      
      # Generate basic shapes
      {:ok, message} = MagicaX.VoxGenerator.generate_cube("cube.vox", 10)
      {:ok, message} = MagicaX.VoxGenerator.generate_sphere("sphere.vox", 8)
  """

  @doc """
  Generates a new VOX file with specified dimensions and voxel data.
  
  ## Parameters
  
  - `filename` - Output VOX file path
  - `dimensions` - Tuple of `{x, y, z}` dimensions
  - `voxels` - List of `{x, y, z, color_index}` tuples
  - `palette` - Optional custom palette (defaults to built-in palette)
  
  ## Returns
  
  - `{:ok, message}` - Success message
  - `{:error, reason}` - Error description
  """
  def generate_vox_file(filename, dimensions, voxels, palette \\ nil) do
    vox_data = create_vox_structure(dimensions, voxels, palette)

    case File.write(filename, vox_data) do
      :ok -> {:ok, "VOX file created successfully: #{filename}"}
      {:error, reason} -> {:error, "Failed to write file: #{reason}"}
    end
  end

  @doc """
  Generates a VOX file from JSON data.
  
  ## JSON Structure
  
      {
        "dimensions": [x, y, z],           // REQUIRED: 3D dimensions
        "voxels": [                        // REQUIRED: Array of voxel objects
          {
            "x": 0,                        // REQUIRED: X coordinate (0-255)
            "y": 0,                        // REQUIRED: Y coordinate (0-255)
            "z": 0,                        // REQUIRED: Z coordinate (0-255)
            "color_index": 1               // REQUIRED: Color index (0-255)
          }
        ],
        "palette": [                       // OPTIONAL: Custom color palette
          {
            "r": 255,                      // REQUIRED: Red component (0-255)
            "g": 255,                      // REQUIRED: Green component (0-255)
            "b": 255,                      // REQUIRED: Blue component (0-255)
            "a": 255                       // REQUIRED: Alpha component (0-255)
          }
        ],
        "metadata": {                      // OPTIONAL: File metadata
          "name": "My VOX Model",
          "author": "Creator Name",
          "description": "Model description"
        }
      }
  
  ## Example
  
      json = \"""
      {
        "dimensions": [10, 10, 10],
        "voxels": [
          {"x": 0, "y": 0, "z": 0, "color_index": 1},
          {"x": 1, "y": 0, "z": 0, "color_index": 2}
        ]
      }
      \"""
      MagicaX.VoxGenerator.generate_from_json("output.vox", json)
  """
  def generate_from_json(filename, json_string) do
    case parse_json(json_string) do
      {:ok, data} -> generate_from_map(filename, data)
      {:error, reason} -> {:error, "Invalid JSON: #{reason}"}
    end
  end

  @doc """
  Generates a VOX file from a parsed JSON map.
  """
  def generate_from_map(filename, data) do
    case validate_json_data(data) do
      {:ok, validated_data} ->
        dimensions =
          validated_data["dimensions"]
          |> Enum.map(&to_integer/1)
          |> List.to_tuple()

        voxels = parse_voxels_from_json(validated_data["voxels"])
        palette = parse_palette_from_json(validated_data["palette"])

        generate_vox_file(filename, dimensions, voxels, palette)

      {:error, reason} ->
        {:error, "Validation failed: #{reason}"}
    end
  end

  @doc """
  Generates a VOX file from a JSON file with automatic output naming.
  
  If no output filename is provided, it will use the same name as the JSON file
  but with .vox extension.
  
  ## Examples
  
      # Creates model.vox from model.json
      MagicaX.VoxGenerator.generate_from_json_file("model.json")
      
      # Creates custom.vox from model.json
      MagicaX.VoxGenerator.generate_from_json_file("model.json", "custom.vox")
  """
  def generate_from_json_file(json_filename, output_filename \\ nil) do
    output_filename = output_filename || String.replace(json_filename, ".json", ".vox")

    case File.read(json_filename) do
      {:ok, json_content} ->
        case generate_from_json(output_filename, json_content) do
          {:ok, message} ->
            {:ok, "Generated #{output_filename} from #{json_filename}: #{message}"}

          {:error, reason} ->
            {:error, "Failed to generate from JSON: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Failed to read JSON file #{json_filename}: #{reason}"}
    end
  end

  @doc """
  Creates a simple cube VOX file.
  
  ## Parameters
  
  - `filename` - Output VOX file path
  - `size` - Cube size (default: 10)
  
  ## Returns
  
  - `{:ok, message}` - Success message
  - `{:error, reason}` - Error description
  """
  def generate_cube(filename, size \\ 10) do
    dimensions = {size, size, size}
    voxels = create_cube_voxels(size)
    palette = create_default_palette()

    generate_vox_file(filename, dimensions, voxels, palette)
  end

  @doc """
  Creates a sphere VOX file.
  
  ## Parameters
  
  - `filename` - Output VOX file path
  - `radius` - Sphere radius (default: 10)
  """
  def generate_sphere(filename, radius \\ 10) do
    dimensions = {radius * 2 + 1, radius * 2 + 1, radius * 2 + 1}
    voxels = create_sphere_voxels(radius)
    palette = create_default_palette()

    generate_vox_file(filename, dimensions, voxels, palette)
  end

  @doc """
  Creates a teapot-like shape VOX file.
  
  ## Parameters
  
  - `filename` - Output VOX file path
  - `scale` - Scale factor (default: 1.0)
  """
  def generate_teapot(filename, scale \\ 1.0) do
    dimensions = {trunc(126 * scale), trunc(80 * scale), trunc(61 * scale)}
    voxels = create_teapot_voxels(scale)
    palette = create_default_palette()

    generate_vox_file(filename, dimensions, voxels, palette)
  end

  # Private functions for VOX file creation

  defp create_vox_structure(dimensions, voxels, palette) do
    header = <<"VOX ", 200::little-integer-size(32)>>
    main_content = create_chunks(dimensions, voxels, palette)
    main_chunk = create_chunk("MAIN", "", main_content)

    header <> main_chunk
  end

  defp create_chunks(dimensions, voxels, palette) do
    size_chunk = create_size_chunk(dimensions)
    xyzi_chunk = create_xyzi_chunk(voxels)
    rgba_chunk = create_rgba_chunk(palette)

    size_chunk <> xyzi_chunk <> rgba_chunk
  end

  defp create_chunk(chunk_id, content, children) do
    content_size = byte_size(content)
    children_size = byte_size(children)

    <<chunk_id::binary-size(4), content_size::little-integer-size(32),
      children_size::little-integer-size(32), content::binary, children::binary>>
  end

  defp create_size_chunk({x, y, z}) do
    content =
      <<x::little-integer-size(32), y::little-integer-size(32), z::little-integer-size(32)>>

    create_chunk("SIZE", content, "")
  end

  defp create_xyzi_chunk(voxels) do
    num_voxels = length(voxels)

    voxel_data =
      Enum.reduce(voxels, <<>>, fn {x, y, z, color_index}, acc ->
        acc <> <<x::8, y::8, z::8, color_index::8>>
      end)

    content = <<num_voxels::little-integer-size(32), voxel_data::binary>>
    create_chunk("XYZI", content, "")
  end

  defp create_rgba_chunk(palette) do
    content =
      Enum.reduce(palette, <<>>, fn {r, g, b, a}, acc ->
        acc <> <<r::8, g::8, b::8, a::8>>
      end)

    create_chunk("RGBA", content, "")
  end

  # Voxel generation functions

  defp create_cube_voxels(size) do
    voxels = []

    # Bottom face (z=0)
    voxels =
      for x <- 0..(size - 1), y <- 0..(size - 1), reduce: voxels do
        acc -> [{x, y, 0, 1} | acc]
      end

    # Top face (z=size-1)
    voxels =
      for x <- 0..(size - 1), y <- 0..(size - 1), reduce: voxels do
        acc -> [{x, y, size - 1, 1} | acc]
      end

    # Left face (x=0)
    voxels =
      for y <- 0..(size - 1), z <- 0..(size - 1), reduce: voxels do
        acc -> [{0, y, z, 1} | acc]
      end

    # Right face (x=size-1)
    voxels =
      for y <- 0..(size - 1), z <- 0..(size - 1), reduce: voxels do
        acc -> [{size - 1, y, z, 1} | acc]
      end

    # Front face (y=0)
    voxels =
      for x <- 0..(size - 1), z <- 0..(size - 1), reduce: voxels do
        acc -> [{x, 0, z, 1} | acc]
      end

    # Back face (y=size-1)
    voxels =
      for x <- 0..(size - 1), z <- 0..(size - 1), reduce: voxels do
        acc -> [{x, size - 1, z, 1} | acc]
      end

    voxels
  end

  defp create_sphere_voxels(radius) do
    center = radius
    radius_squared = radius * radius

    for x <- 0..(radius * 2),
        y <- 0..(radius * 2),
        z <- 0..(radius * 2),
        reduce: [] do
      acc ->
        dx = x - center
        dy = y - center
        dz = z - center
        distance_squared = dx * dx + dy * dy + dz * dz

        if distance_squared <= radius_squared do
          [{x, y, z, 1} | acc]
        else
          acc
        end
    end
  end

  defp create_teapot_voxels(scale) do
    base_radius = trunc(20 * scale)
    height = trunc(40 * scale)
    spout_length = trunc(15 * scale)

    voxels = []

    # Base
    voxels = add_cylinder_voxels(voxels, {base_radius, base_radius, 0}, base_radius, 5, 1)

    # Body
    voxels =
      add_cylinder_voxels(voxels, {base_radius, base_radius, 5}, base_radius - 2, height - 10, 2)

    # Spout
    spout_start = {base_radius + spout_length, base_radius, height - 15}
    voxels = add_cylinder_voxels(voxels, spout_start, 3, 10, 3)

    # Handle
    handle_center = {base_radius - 5, base_radius, height - 20}
    voxels = add_torus_voxels(voxels, handle_center, 8, 3, 4)

    voxels
  end

  defp add_cylinder_voxels(voxels, {cx, cy, cz}, radius, height, color) do
    for x <- (cx - radius)..(cx + radius),
        y <- (cy - radius)..(cy + radius),
        z <- cz..(cz + height - 1),
        reduce: voxels do
      acc ->
        dx = x - cx
        dy = y - cy

        if dx * dx + dy * dy <= radius * radius do
          [{x, y, z, color} | acc]
        else
          acc
        end
    end
  end

  defp add_torus_voxels(voxels, {cx, cy, cz}, major_radius, minor_radius, color) do
    for x <- (cx - major_radius - minor_radius)..(cx + major_radius + minor_radius),
        y <- (cy - major_radius - minor_radius)..(cy + major_radius + minor_radius),
        z <- (cz - minor_radius)..(cz + minor_radius),
        reduce: voxels do
      acc ->
        dx = x - cx
        dy = y - cy
        dz = z - cz

        major_dist = :math.sqrt(dx * dx + dy * dy)
        minor_dist =
          :math.sqrt((major_dist - major_radius) * (major_dist - major_radius) + dz * dz)

        if minor_dist <= minor_radius do
          [{x, y, z, color} | acc]
        else
          acc
        end
    end
  end

  defp create_default_palette do
    base_colors = [
      {255, 255, 255, 255},  # White
      {255, 0, 0, 255},      # Red
      {0, 255, 0, 255},      # Green
      {0, 0, 255, 255},      # Blue
      {255, 255, 0, 255},    # Yellow
      {255, 0, 255, 255},    # Magenta
      {0, 255, 255, 255},    # Cyan
      {128, 128, 128, 255},  # Gray
      {255, 128, 0, 255},    # Orange
      {128, 0, 255, 255},    # Purple
      {0, 128, 255, 255},    # Light Blue
      {255, 128, 128, 255},  # Light Red
      {128, 255, 128, 255},  # Light Green
      {255, 255, 128, 255},  # Light Yellow
      {128, 128, 255, 255},  # Light Purple
      {255, 128, 255, 255}   # Light Magenta
    ]

    palette = base_colors

    # Add more colors by varying the base colors
    for color <- base_colors,
        variation <- [0.5, 0.75, 1.25, 1.5],
        reduce: palette do
      acc ->
        {r, g, b, a} = color

        new_color = {
          trunc(r * variation),
          trunc(g * variation),
          trunc(b * variation),
          a
        }

        [new_color | acc]
    end
    |> Enum.take(256)
    |> Enum.reverse()
  end

  # Simple JSON parser (no external dependencies)

  defp parse_json(json_string) do
    try do
      cleaned =
        json_string
        |> String.replace(~r/\s+/, "")
        |> String.replace("\n", "")
        |> String.replace("\r", "")

      case parse_json_value(cleaned) do
        {parsed_data, ""} ->
          {:ok, parsed_data}

        {parsed_data, remaining} ->
          if String.trim(remaining) == "" do
            {:ok, parsed_data}
          else
            {:error, "Unexpected content after JSON: #{remaining}"}
          end

        _ ->
          {:error, "Failed to parse JSON"}
      end
    rescue
      e -> {:error, "JSON parsing error: #{inspect(e)}"}
    end
  end

  defp parse_json_value(<<"{", rest::binary>>) do
    parse_object(rest, %{})
  end

  defp parse_json_value(<<"[", rest::binary>>) do
    parse_array(rest, [])
  end

  defp parse_json_value(<<"\"", rest::binary>>) do
    parse_string(rest)
  end

  defp parse_json_value(<<"true", rest::binary>>) do
    {true, rest}
  end

  defp parse_json_value(<<"false", rest::binary>>) do
    {false, rest}
  end

  defp parse_json_value(<<"null", rest::binary>>) do
    {nil, rest}
  end

  defp parse_json_value(<<digit::8, rest::binary>>) when digit in ?0..?9 or digit == ?- do
    parse_number(<<digit>>, rest)
  end

  defp parse_json_value(_), do: {:error, "Invalid JSON value"}

  defp parse_object(<<"}", rest::binary>>, acc) do
    {acc, rest}
  end

  defp parse_object(<<"\"", rest::binary>>, acc) do
    {key, rest_after_key} = parse_string(rest)
    <<":", rest_after_colon::binary>> = rest_after_key
    {value, rest_after_value} = parse_json_value(rest_after_colon)

    new_acc = Map.put(acc, key, value)

    case rest_after_value do
      <<",", rest_after_comma::binary>> -> parse_object(rest_after_comma, new_acc)
      <<"}", rest_after_brace::binary>> -> {new_acc, rest_after_brace}
      _ -> {new_acc, rest_after_value}
    end
  end

  defp parse_array(<<"]", rest::binary>>, acc) do
    {Enum.reverse(acc), rest}
  end

  defp parse_array(rest, acc) do
    {value, rest_after_value} = parse_json_value(rest)
    new_acc = [value | acc]

    case rest_after_value do
      <<",", rest_after_comma::binary>> -> parse_array(rest_after_comma, new_acc)
      <<"]", rest_after_bracket::binary>> -> {Enum.reverse(new_acc), rest_after_bracket}
      _ -> {Enum.reverse(new_acc), rest_after_value}
    end
  end

  defp parse_string(rest) do
    case String.split(rest, "\"", parts: 2) do
      [string_content, remaining] -> {string_content, remaining}
      _ -> {"", rest}
    end
  end

  defp parse_number(acc, <<digit::8, rest::binary>>) when digit in ?0..?9 do
    parse_number(acc <> <<digit>>, rest)
  end

  defp parse_number(acc, <<".", rest::binary>>) do
    parse_number(acc <> ".", rest)
  end

  defp parse_number(acc, rest) do
    case Float.parse(acc) do
      {float, ""} ->
        {float, rest}

      _ ->
        case Integer.parse(acc) do
          {int, ""} -> {int, rest}
          _ -> {:error, "Invalid number: #{acc}"}
        end
    end
  end

  # Helper functions for JSON generation

  defp validate_json_data(data) do
    required_keys = ["dimensions", "voxels"]
    missing_keys = required_keys -- Map.keys(data)

    if missing_keys != [] do
      {:error, "Missing required keys: #{missing_keys}"}
    else
      {:ok, data}
    end
  end

  defp parse_voxels_from_json(voxels_json) do
    voxels_json
    |> Enum.map(fn voxel ->
      {
        Map.fetch!(voxel, "x") |> to_integer(),
        Map.fetch!(voxel, "y") |> to_integer(),
        Map.fetch!(voxel, "z") |> to_integer(),
        Map.fetch!(voxel, "color_index") |> to_integer()
      }
    end)
  end

  defp parse_palette_from_json(palette_json) do
    palette_json
    |> Enum.map(fn color ->
      {
        Map.fetch!(color, "r") |> to_integer(),
        Map.fetch!(color, "g") |> to_integer(),
        Map.fetch!(color, "b") |> to_integer(),
        Map.fetch!(color, "a") |> to_integer()
      }
    end)
  end

  defp to_integer(value) when is_integer(value), do: value
  defp to_integer(value) when is_float(value), do: trunc(value)

  defp to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> raise ArgumentError, "Invalid integer value: #{value}"
    end
  end

  defp to_integer(_), do: 0
end
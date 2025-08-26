defmodule MagicaX do
  @moduledoc """
  MagicaX - Elixir toolkit for parsing and generating MagicaVoxel (.vox) files.

  MagicaX provides two main components:

  - `MagicaX.VoxParser` - Complete VOX file parser with 99.85% data coverage
  - `MagicaX.VoxGenerator` - Flexible VOX file generator with multiple input methods

  ## Quick Start

  ### Parsing a VOX file

      {:ok, data} = MagicaX.parse_file("model.vox")
      IO.inspect(data.size)     # {32, 32, 32}
      IO.inspect(data.voxels)   # [{0, 0, 0, 1}, {1, 0, 0, 2}, ...]

  ### Generating a VOX file

      # From JSON
      {:ok, message} = MagicaX.generate_from_json_file("model.json")

      # Basic shapes
      {:ok, message} = MagicaX.generate_cube("cube.vox", 10)
      {:ok, message} = MagicaX.generate_sphere("sphere.vox", 8)

      # Programmatically
      dimensions = {10, 10, 10}
      voxels = [{0, 0, 0, 1}, {1, 1, 1, 2}]
      {:ok, message} = MagicaX.generate_vox_file("model.vox", dimensions, voxels)

  ## Data Structures

  ### Voxels
  Represented as tuples of `{x, y, z, color_index}` where coordinates are 0-255.

  ### Palette
  Color definitions as tuples of `{r, g, b, a}` with 256 color entries.

  ### Dimensions
  Model size as tuples of `{x_size, y_size, z_size}`.

  ## Supported Features

  ### Parser Features
  - All major chunk types (SIZE, XYZI, RGBA, MATL, LAYR, rOBJ, rCAM, NOTE, nTRN, nSHP, nGRP, META)
  - 3D matrix representation for spatial operations
  - Comprehensive chunk analysis and statistics
  - Graceful error handling with detailed reporting

  ### Generator Features
  - JSON-to-VOX conversion with validation
  - Programmatic voxel creation
  - Built-in shape generators (cube, sphere, teapot)
  - Custom palette support
  - No external dependencies
  """

  alias MagicaX.VoxParser
  alias MagicaX.VoxGenerator

  @doc """
  Parses a VOX file and returns structured data.

  This is a convenience function that delegates to `MagicaX.VoxParser.parse_vox_file/1`.

  ## Parameters

  - `filename` - Path to the VOX file to parse

  ## Returns

  - `{:ok, data}` - Successfully parsed data structure
  - `{:error, reason}` - Parse error with description

  ## Examples

      {:ok, data} = MagicaX.parse_file("model.vox")
      IO.inspect(data.size)     # {32, 32, 32}
      IO.inspect(length(data.voxels))  # 1024
  """
  defdelegate parse_file(filename), to: VoxParser, as: :parse_vox_file

  @doc """
  Generates a VOX file from dimensions, voxels, and optional palette.

  This is a convenience function that delegates to `MagicaX.VoxGenerator.generate_vox_file/4`.

  ## Parameters

  - `filename` - Output VOX file path
  - `dimensions` - Tuple of `{x, y, z}` dimensions
  - `voxels` - List of `{x, y, z, color_index}` tuples
  - `palette` - Optional custom palette (defaults to built-in palette)

  ## Examples

      dimensions = {10, 10, 10}
      voxels = [{0, 0, 0, 1}, {1, 1, 1, 2}, {2, 2, 2, 3}]
      {:ok, message} = MagicaX.generate_vox_file("model.vox", dimensions, voxels)
  """
  defdelegate generate_vox_file(filename, dimensions, voxels, palette \\ nil), to: VoxGenerator

  @doc """
  Generates a VOX file from JSON data.

  This is a convenience function that delegates to `MagicaX.VoxGenerator.generate_from_json/2`.

  ## Parameters

  - `filename` - Output VOX file path
  - `json_string` - JSON string containing model data

  ## JSON Structure

      {
        "dimensions": [x, y, z],           // REQUIRED
        "voxels": [                        // REQUIRED
          {"x": 0, "y": 0, "z": 0, "color_index": 1}
        ],
        "palette": [                       // OPTIONAL
          {"r": 255, "g": 0, "b": 0, "a": 255}
        ]
      }

  ## Examples

      json = ~s({"dimensions": [5,5,5], "voxels": [{"x":0,"y":0,"z":0,"color_index":1}]})
      {:ok, message} = MagicaX.generate_from_json("model.vox", json)
  """
  defdelegate generate_from_json(filename, json_string), to: VoxGenerator

  @doc """
  Generates a VOX file from a JSON file.

  This is a convenience function that delegates to `MagicaX.VoxGenerator.generate_from_json_file/2`.

  ## Parameters

  - `json_filename` - Path to JSON file containing model data
  - `output_filename` - Optional output VOX file path (defaults to JSON filename with .vox extension)

  ## Examples

      # Creates model.vox from model.json
      {:ok, message} = MagicaX.generate_from_json_file("model.json")

      # Creates custom.vox from model.json
      {:ok, message} = MagicaX.generate_from_json_file("model.json", "custom.vox")
  """
  defdelegate generate_from_json_file(json_filename, output_filename \\ nil), to: VoxGenerator

  @doc """
  Generates a cube VOX file.

  This is a convenience function that delegates to `MagicaX.VoxGenerator.generate_cube/2`.

  ## Parameters

  - `filename` - Output VOX file path
  - `size` - Cube size (default: 10)

  ## Examples

      {:ok, message} = MagicaX.generate_cube("cube.vox", 15)
  """
  defdelegate generate_cube(filename, size \\ 10), to: VoxGenerator

  @doc """
  Generates a sphere VOX file.

  This is a convenience function that delegates to `MagicaX.VoxGenerator.generate_sphere/2`.

  ## Parameters

  - `filename` - Output VOX file path
  - `radius` - Sphere radius (default: 10)

  ## Examples

      {:ok, message} = MagicaX.generate_sphere("sphere.vox", 12)
  """
  defdelegate generate_sphere(filename, radius \\ 10), to: VoxGenerator

  @doc """
  Generates a teapot VOX file.

  This is a convenience function that delegates to `MagicaX.VoxGenerator.generate_teapot/2`.

  ## Parameters

  - `filename` - Output VOX file path
  - `scale` - Scale factor (default: 1.0)

  ## Examples

      {:ok, message} = MagicaX.generate_teapot("teapot.vox", 0.5)
  """
  defdelegate generate_teapot(filename, scale \\ 1.0), to: VoxGenerator

  @doc """
  Returns the version of the MagicaX library.

  ## Examples

      MagicaX.version()  # "0.1.0"
  """
  def version do
    Application.spec(:magicax, :vsn) |> to_string()
  end
end

defmodule Exgrep.Process do
  @spec process_input(String.t(), String.t()) :: [{String.t(), integer()}]
  def process_input(input_file, pattern) do
    chunk_size = 2

    input_file
    |> read_file_as_stream()
    |> trim_lines_and_add_index()
    |> Stream.chunk_every(chunk_size)
    |> Task.async_stream(fn batch -> filter_lines_matching_pattern(batch, pattern) end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> List.flatten()
  end

  @spec read_file_as_stream(String.t()) :: File.Stream.t()
  defp read_file_as_stream(input_file) do
    Path.expand(input_file)
    |> File.stream!(:line)
  end

  @spec trim_lines_and_add_index(File.Stream.t()) :: Stream.t({String.t(), integer()})
  defp trim_lines_and_add_index(input_stream) do
    input_stream
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
  end

  @spec filter_lines_matching_pattern([{String.t(), integer()}], String.t()) :: [
          {String.t(), integer()}
        ]
  defp filter_lines_matching_pattern(batch, pattern) do
    batch
    |> Enum.filter(fn {line, _} -> line_contains_pattern?(line, pattern) end)
    |> Enum.map(fn {line, index} -> {line, index} end)
  end

  @spec line_contains_pattern?(String.t(), String.t()) :: boolean()
  defp line_contains_pattern?(line, pattern) do
    String.contains?(line, pattern)
  end
end

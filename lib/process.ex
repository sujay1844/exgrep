defmodule FileHandler do
  @spec read(String.t()) :: File.Stream.t()
  def read(input_file) do
    Path.expand(input_file)
    |> File.stream!(:line)
  end
end

defmodule Processor do
  @spec process_input(
          File.Stream.t(),
          (String.t() -> boolean()),
          integer()
        ) :: [{String.t(), integer()}]
  def process_input(file_stream, match_fn, chunk_size) do
    file_stream
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.chunk_every(chunk_size)
    |> Task.async_stream(fn batch -> filter_lines_matching_pattern(batch, match_fn) end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> List.flatten()
  end

  @spec filter_lines_matching_pattern(
          Stream.t({String.t(), integer()}),
          (String.t() -> boolean())
        ) :: Stream.t({String.t(), integer()})
  defp filter_lines_matching_pattern(batch, match_fn) do
    batch
    |> Enum.filter(fn {line, _} -> match_fn.(line) end)
    |> Enum.map(fn {line, index} -> {line, index} end)
  end
end

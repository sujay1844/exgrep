defmodule Exgrep.Process do
  @chunk_size 2

  @spec process_input(String.t(), String.t()) :: [{String.t(), integer}]
  def process_input(input_file, pattern) do
    Path.expand(input_file)
    |> File.stream!(:line)
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.chunk_every(@chunk_size)
    |> Task.async_stream(fn batch -> process_batch(batch, pattern) end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> List.flatten()
  end

  @spec process_batch([String.t()], String.t()) :: [{String.t(), integer}]
  def process_batch(batch, pattern) do
    batch
    |> Enum.filter(fn {line, _} -> String.contains?(line, pattern) end)
  end
end

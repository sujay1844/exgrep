defmodule Exgrep do
  @spec main([String.t()]) :: :ok
  def main(args) do
    opts = [
      aliases: [h: :help],
      switches: [
        help: :boolean,
        exact: :boolean,
        ignorecase: :boolean
      ]
    ]

    case OptionParser.parse(args, opts) do
      {[help: true], _, _} ->
        help_message()

      {options, [pattern, input_file], _} ->
        match_fn =
          case options do
            [exact: true, ignorecase: true] ->
              fn line -> String.contains?(String.downcase(line), String.downcase(pattern)) end

            [exact: true] ->
              fn line -> String.contains?(line, pattern) end

            [ignorecase: true] ->
              try do
                fn line -> Regex.match?(Regex.compile!(pattern, "i"), line) end
              rescue
                e in [Regex.CompileError, ArgumentError] ->
                  IO.puts("Invalid regex: #{pattern}\nError: #{e}")
                  System.halt(1)
              end

            _ ->
              try do
                fn line -> Regex.match?(Regex.compile!(pattern), line) end
              rescue
                e in [Regex.CompileError, ArgumentError] ->
                  IO.puts("Invalid regex: #{pattern}\nError: #{e}")
                  System.halt(1)
              end
          end

        chunk_size = 2

        FileHandler.read(input_file)
        |> Processor.process_input(match_fn, chunk_size)
        |> Enum.map(fn {line, index} -> IO.puts("#{index}: #{line}") end)

      _ ->
        help_message()
    end
  end

  @spec help_message() :: :ok
  defp help_message do
    IO.puts("""
    Usage: exgrep [OPTION]... PATTERN FILE

    Options:
    -h, --help
    """)
  end
end

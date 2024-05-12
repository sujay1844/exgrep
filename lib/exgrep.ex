defmodule Exgrep do
  @spec main([String.t()]) :: :ok
  def main(args) do
    opts = [
      aliases: [h: :help],
      switches: [help: :boolean]
    ]

    case OptionParser.parse(args, opts) do
      {[help: true], _, _} ->
        help_message()

      {_, [pattern, input_file], _} ->
        Exgrep.Process.process_input(input_file, pattern)
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

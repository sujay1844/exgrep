defmodule PatternMatcher do
  @spec exact_match?(String.t(), String.t()) :: boolean()
  def exact_match?(line, pattern) do
    String.contains?(line, pattern)
  end

  @spec match?(String.t(), Regex.t()) :: boolean()
  def match?(line, regex) do
    Regex.match?(regex, line)
  end
end

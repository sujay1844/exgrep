defmodule ExgrepTest do
  use ExUnit.Case
  doctest Exgrep

  test "greets the world" do
    assert Exgrep.hello() == :world
  end
end

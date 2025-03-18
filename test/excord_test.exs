defmodule ExcordTest do
  use ExUnit.Case
  doctest Excord

  test "greets the world" do
    assert Excord.hello() == :world
  end
end

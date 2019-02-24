defmodule FoobarTest do
  use ExUnit.Case
  doctest Foobar

  test "greets the world" do
    assert Foobar.hello() == :world
  end
end

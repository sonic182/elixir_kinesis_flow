defmodule SampleappTest do
  use ExUnit.Case
  doctest Sampleapp

  test "greets the world" do
    assert Sampleapp.hello() == :world
  end
end

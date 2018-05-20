defmodule DaffybotTest do
  use ExUnit.Case
  doctest Daffybot

  test "greets the world" do
    assert Daffybot.hello() == :world
  end
end

ExUnit.start

Code.require_file "./07.exs"

defmodule SantaTest do
  use ExUnit.Case, async: true

  test "the thing" do
    mapping = Santa.load("07sample.txt")

    assert Santa.look_up_value(mapping, "d") == 72
    assert Santa.look_up_value(mapping, "e") == 507
    assert Santa.look_up_value(mapping, "f") == 492
    assert Santa.look_up_value(mapping, "g") == 114
    assert Santa.look_up_value(mapping, "h") == 65412
    assert Santa.look_up_value(mapping, "i") == 65079
    assert Santa.look_up_value(mapping, "x") == 123
    assert Santa.look_up_value(mapping, "y") == 456
  end
end

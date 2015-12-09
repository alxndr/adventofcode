defmodule Santa do
  use Bitwise, only_operators: true

  @result_marker "->"

  def read_lines(filename) do
    {:ok, contents} = File.read(filename)
    String.split contents, "\n"
  end

  def load(filename\\"07sample.txt") do
    filename
    |> read_lines
    |> build_mapping
  end

  def build_mapping(lines) do
    lines
    |> Stream.map(&String.strip/1)
    |> Enum.reduce(%{}, &interpret_line/2)
  end

  def interpret_line("", values), do: values
  def interpret_line(line, values) do
    [wire_label, "->" | instructions] =
      line
      |> String.split(" ")
      |> Enum.reverse # reversing so I can use [a, b | c] to separate the instructions...
    instructions = Enum.reverse(instructions) # ...now put those back in order
    Map.put(values, wire_label, instructions)
  end

  def look_up_value(mapping, var) do
    value =
      mapping
      |> Map.fetch!(var)
      |> calculate_value(mapping)
    if value < 0 do
      value + 65536
    else
      value
    end
  end

  # n.b. this recursion is not optimized
  def calculate_value([value], _values) when value in "0".."9999" do
    IO.puts "to integer: #{value}"
    String.to_integer(value)
  end
  def calculate_value([variable], values) when variable in "a".."zz" do
    IO.puts "look up: #{variable}"
    {:ok, value} = Map.fetch(values, variable)
    calculate_value(value, values)
  end
  def calculate_value(["NOT" | instructions], values) do
    IO.puts "not: #{inspect instructions}"
    value = calculate_value(instructions, values)
    Bitwise.bnot(value)
  end
  def calculate_value([variable1, "AND", variable2], values) do
    IO.puts "and: #{inspect variable1}, #{inspect variable2}"
    Bitwise.band(calculate_value([variable1], values), calculate_value([variable2], values))
  end
  def calculate_value([variable1, "OR", variable2], values) do
    IO.puts "or: #{inspect variable1}, #{inspect variable2}"
    Bitwise.bor(calculate_value([variable1], values), calculate_value([variable2], values))
  end
  def calculate_value([variable1, "LSHIFT", variable2], values) do
    IO.puts "lshift: #{inspect variable1}, #{inspect variable2}"
    Bitwise.bsl(calculate_value([variable1], values), calculate_value([variable2], values))
  end
  def calculate_value([variable1, "RSHIFT", variable2], values) do
    IO.puts "rshift: #{inspect variable1}, #{inspect variable2}"
    Bitwise.bsr(calculate_value([variable1], values), calculate_value([variable2], values))
  end
  def calculate_value(instructions, values) do
    IO.puts "uh oh... something broke"
    IO.inspect instructions
    IO.puts "==========="
    IO.inspect values
  end

end

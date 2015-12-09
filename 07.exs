defmodule Santa do
  use Bitwise, only_operators: true

  @result_marker "->"

  def read_lines(filename) do
    {:ok, contents} = File.read(filename)
    String.split contents, "\n"
  end

  def load(filename\\"07sample.txt") do
    IO.puts "reading from #{filename}"
    filename
    |> read_lines
    |> interpret
  end

  def interpret(lines) do
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
    value = calculate_value(instructions, values)
    if value < 0 do
      value = value + 65536 # sample shows positive values
    end
    IO.puts "#{inspect instructions} : #{inspect value}"
    Map.put(values, wire_label, value)
  end

  # n.b. this recursion is not optimized
  def calculate_value([value], _values) when value in "1".."99999" do
    String.to_integer value
  end
  def calculate_value([variable], values) when variable in "a".."zz" do
    Map.get(values, variable, variable)
  end
  def calculate_value(["NOT" | instructions], values) do
    Bitwise.bnot(calculate_value(instructions, values))
  end
  def calculate_value([variable1, "AND", variable2], values) do
    Bitwise.band(calculate_value([variable1], values), calculate_value([variable2], values))
  end
  def calculate_value([variable1, "OR", variable2], values) do
    Bitwise.bor(calculate_value([variable1], values), calculate_value([variable2], values))
  end
  def calculate_value([variable1, "LSHIFT", variable2], values) do
    Bitwise.bsl(calculate_value([variable1], values), calculate_value([variable2], values))
  end
  def calculate_value([variable1, "RSHIFT", variable2], values) do
    Bitwise.bsr(calculate_value([variable1], values), calculate_value([variable2], values))
  end
  def calculate_value(instructions, values) do
    IO.puts "uh oh... something broke"
    IO.inspect instructions
    IO.puts "==========="
    IO.inspect values
  end

end

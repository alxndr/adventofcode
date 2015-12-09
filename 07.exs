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
      |> IO.inspect
      |> calculate_value(mapping)
    if value < 0 do
      value + 65536
    else
      value
    end
  end

  def calculate_value(n, values) when is_integer(n), do: {n, values}
  def calculate_value([value], values) when value in "0".."9999" do
    new_value = String.to_integer(value)
    {new_value, values}
  end
  def calculate_value([variable], values) when variable in "a".."zz" do
    {:ok, value} = Map.fetch(values, variable)
    {new_value, new_values} = calculate_value(value, values)
    newer_values = Map.put(new_values, variable, new_value) # here's the real memoization?
    {new_value, newer_values}
  end
  def calculate_value(["NOT" | instructions], values) do
    IO.puts "not: #{inspect instructions}"
    {new_value, new_values} = calculate_value(instructions, values)
    {Bitwise.bnot(new_value), new_values}
  end
  def calculate_value([variable1, operation, variable2], values) do
    {new_value1, new_values} = calculate_value([variable1], values)
    newer_values = Map.put(new_values, variable1, new_value1)
    {new_value2, newerr_values} = calculate_value([variable2], newer_values)
    newest_values = Map.put(newerr_values, variable2, new_value2)
    {handle_operation(new_value1, operation, new_value2), newest_values}
  end
  def calculate_value(instructions, values) do
    IO.puts "uh oh... something broke"
    IO.inspect instructions
    IO.puts "==========="
    IO.inspect values
  end

  def handle_operation(leftval, "AND", rightval) do
    Bitwise.band(leftval, rightval)
  end
  def handle_operation(leftval, "OR", rightval) do
    Bitwise.bor(leftval, rightval)
  end
  def handle_operation(leftval, "LSHIFT", rightval) do
    Bitwise.bsl(leftval, rightval)
  end
  def handle_operation(leftval, "RSHIFT", rightval) do
    Bitwise.bsr(leftval, rightval)
  end

end

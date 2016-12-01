defmodule AuntDetector do

  @regex_aunt_stat_line ~r/(?<identifier>Sue \d+): (?<stat1>\w+): (?<quantity1>\d+), (?<stat2>\w+): (?<quantity2>\d+), (?<stat3>\w+): (?<quantity3>\d+)/
  @looking_for %{
    children: 3,
    cats: 7,
    samoyeds: 2,
    pomeranians: 3,
    akitas: 0,
    vizslas: 0,
    goldfish: 5,
    trees: 3,
    cars: 2,
    perfumes: 1,
  }

  def load(filename\\"16small.txt") do
    {:ok, contents} = File.read(filename)
    contents
    |> String.strip
    |> String.split("\n")
  end

  def build_map(aunt_lines) do
    Enum.reduce(aunt_lines, [], fn (aunt_line, aunts_and_stats_list) ->
      aunt_stats = Regex.named_captures(@regex_aunt_stat_line, aunt_line)
      [ aunt_stats | aunts_and_stats_list ]
    end)
  end

  def look_for_things(aunt_and_stats_list, looking_for \\ @looking_for) do
    Enum.filter(aunt_and_stats_list, fn (aunt_stats) ->
      attribute1 = String.to_atom(aunt_stats["stat1"])
      attribute2 = String.to_atom(aunt_stats["stat2"])
      attribute3 = String.to_atom(aunt_stats["stat3"])
      quantity1 = String.to_integer(aunt_stats["quantity1"])
      quantity2 = String.to_integer(aunt_stats["quantity2"])
      quantity3 = String.to_integer(aunt_stats["quantity3"])
      works?(attribute1, looking_for[attribute1], quantity1) &&
        works?(attribute2, looking_for[attribute2], quantity2) &&
        works?(attribute3, looking_for[attribute3], quantity3)
    end)
  end

  defp works?(type, required_value, testing_value) when (type == :cats or type == :trees) do
    required_value < testing_value
  end
  defp works?(type, required_value, testing_value) when (type == :pomeranians or type == :goldfish) do
    required_value > testing_value
  end
  defp works?(type, required_value, testing_value) when required_value == testing_value, do: true
  defp works?(_type, _required_value, _testing_value), do: false

end

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
    IO.puts "building aunts_and_stats_list..."
    Enum.reduce(aunt_lines, [], fn (aunt_line, aunts_and_stats_list) ->
      aunt_stats = Regex.named_captures(@regex_aunt_stat_line, aunt_line)
      [ aunt_stats | aunts_and_stats_list ]
      # |> IO.inspect
    end)
  end

  def look_for_things(aunt_and_stats_list, looking_for \\ @looking_for) do
    Enum.filter(aunt_and_stats_list, fn (aunt_stats) ->
      IO.inspect aunt_stats
      attribute1 = String.to_atom(aunt_stats["stat1"])
      attribute2 = String.to_atom(aunt_stats["stat2"])
      attribute3 = String.to_atom(aunt_stats["stat3"])
      cond do
        looking_for[attribute1] != String.to_integer(aunt_stats["quantity1"]) -> false
        looking_for[attribute2] != String.to_integer(aunt_stats["quantity2"]) -> false
        looking_for[attribute3] != String.to_integer(aunt_stats["quantity3"]) -> false
        true -> true
      end
      |> IO.inspect
    end)
  end

end

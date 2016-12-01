defmodule Santa do

  @re_instructions ~r/(?<directive>turn on|toggle|turn off) (?<start_coords>\d+,\d+) through (?<end_coords>\d+,\d+)/

  def read_lines(filename) do
    {:ok, contents} = File.read(filename)
    String.split(contents, "\n")
  end

  def do_it(filename\\"06head.txt") do
    filename
    |> read_lines
    |> Enum.reduce(%{}, fn
      ("", lights) -> lights
      (line, lights) ->
        interpret(line, lights)
    end)
    |> count
    |> IO.puts
  end

  def interpret(line, lights_map) do
    %{
      "directive" => directive,
      "start_coords" => start_coords,
      "end_coords" => end_coords
    } = Regex.named_captures(@re_instructions, line)
    [startX, startY] = extract_coords(start_coords)
    [endX, endY] = extract_coords(end_coords)
    IO.puts "#{count lights_map}"
    IO.write "#{directive} #{startX},#{startY} to #{endX},#{endY}... "
    Enum.reduce(startX..endX, lights_map, fn (x, lm1) ->
      Enum.reduce(startY..endY, lm1, fn (y, lm2) ->
        handle(lm2, directive, "#{x}.#{y}")
      end)
    end)
  end

  def handle(lights_map, "turn on", key) do
    previous_value = get(lights_map, key)
    Map.put(lights_map, key, previous_value + 1)
  end
  def handle(lights_map, "turn off", key) do
    previous_value = get(lights_map, key)
    new_value = if previous_value - 1 < 0, do: 0, else: previous_value - 1
    Map.put(lights_map, key, new_value)
  end
  def handle(lights_map, "toggle", key) do
    previous_value = get(lights_map, key)
    Map.put(lights_map, key, previous_value + 2)
  end

  def get(map, key), do: Map.get(map, key, 0)

  def count(lights_map) do
    Enum.reduce(lights_map, 0, fn({_key, brightness}, sum) -> sum + brightness end)
  end

  def extract_coords(coords) do
    coords
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

end

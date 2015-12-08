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
    Map.put(lights_map, key, true)
  end
  def handle(lights_map, "turn off", key) do
    Map.put(lights_map, key, false)
  end
  def handle(lights_map, "toggle", key) do
    Map.put(lights_map, key, !Map.get(lights_map, key, false))
  end

  def count(lights_map) do
    Enum.count(lights_map, &is_value_true?/1)
  end

  def extract_coords(coords) do
    coords
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp is_value_true?({_k, val}) when val == true or val == false, do: val
  defp is_value_true?(otherwise) do
    IO.puts "uh oh what is this"
    IO.inspect otherwise
    true
  end

end

defmodule DinnerTable do

  def load(filename\\"13sample.txt") do
    {:ok, contents} = File.read(filename)
    contents
    |> String.strip
    |> String.split("\n")
  end



end

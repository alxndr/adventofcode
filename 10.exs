defmodule Elf do

  def run_repeats(sequence_str, num_runs) do
    ints = str_to_ints(sequence_str)
    Enum.reduce(1..num_runs, ints, fn (n, ints_in_flux) ->
      result = look_and_say(ints_in_flux)
      IO.puts "run ##{n}: #{Enum.count(result)}"
      result
    end)
    |> Enum.count
  end

  def str_to_ints(str) do
    str
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
  end

  def look_and_say(ints) do
    Enum.reduce(ints, %{results: [], stack: []}, &look_at_letter/2)
    |> finish_up
  end

  def look_at_letter(n, %{results: results, stack: []}) do
    %{results: results, stack: [n]}
  end
  def look_at_letter(n, %{results: results, stack: [x|_]=stack}) when n == x do
    %{results: results, stack: [n|stack]}
  end
  def look_at_letter(n, %{results: results, stack: [x|_]=stack}) when n != x do
    # IO.puts "#{n} is different from #{x} so need to push #{Enum.count(stack)} x #{x}s onto results #{inspect results}"
    new_results = results ++ [Enum.count(stack), x]
    %{results: new_results, stack: [n]}
  end

  def finish_up(%{results: results, stack: []}), do: results
  def finish_up(%{results: results, stack: [n|_]=stack}), do: results ++ [Enum.count(stack), n]

end

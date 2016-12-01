defmodule Chem do
  @replacements [
    Al: [:Th, :F],
    Al: [:Th, :Rn, :F, :Ar],
    B:  [:B, :Ca],
    B:  [:Ti, :B],
    B:  [:Ti, :Rn, :F, :Ar],
    Ca: [:Ca, :Ca],
    Ca: [:P, :B],
    Ca: [:P, :Rn, :F, :Ar],
    Ca: [:Si, :Rn, :F, :Y, :F, :Ar],
    Ca: [:Si, :Rn, :Mg, :Ar],
    Ca: [:Si, :Th],
    F:  [:Ca, :F],
    F:  [:P, :Mg],
    F:  [:Si, :Al],
    H:  [:C, :Rn, :Al, :Ar],
    H:  [:C, :Rn, :F, :Y, :F, :Y, :F, :Ar],
    H:  [:C, :Rn, :F, :Y, :Mg, :Ar],
    H:  [:C, :Rn, :Mg, :Y, :F, :Ar],
    H:  [:H, :Ca],
    H:  [:N, :Rn, :F, :Y, :F, :Ar],
    H:  [:N, :Rn, :Mg, :Ar],
    H:  [:N, :Th],
    H:  [:O, :B],
    H:  [:O, :Rn, :F, :Ar],
    Mg: [:B, :F],
    Mg: [:Ti, :Mg],
    N:  [:C, :Rn, :F, :Ar],
    N:  [:H, :Si],
    O:  [:C, :Rn, :F, :Y, :F, :Ar],
    O:  [:C, :Rn, :Mg, :Ar],
    O:  [:H, :P],
    O:  [:N, :Rn, :F, :Ar],
    O:  [:O, :Ti],
    P:  [:Ca, :P],
    P:  [:P, :Ti],
    P:  [:Si, :Rn, :F, :Ar],
    Si: [:Ca, :Si],
    Th: [:Th, :Ca],
    Ti: [:B, :P],
    Ti: [:Ti, :Ti],
    e:  [:H, :F],
    e:  [:N, :Al],
    e:  [:O, :Mg],
  ]

  @spec string_to_atoms(String.t) :: List
  def string_to_atoms(string) do
    ~r/(?=[A-Z])/
    |> Regex.split(string, trim: true)
    |> Enum.map(&String.to_atom/1)
  end

  @spec generate_replacements(List, List) :: List
  def generate_replacements(molecule, mapping\\@replacements) do
    molecule
    |> Enum.map(fn (atom) ->
      found = Keyword.get_values(mapping, atom)
      IO.puts "#{atom} -> #{inspect found}"
      found
    end)
    |> IO.inspect
  end

  def convert_possibilities_into_molecules(lists) do
  end

end

ExUnit.start
ExUnit.configure(exclude: [skip: true])

defmodule ChemTest do
  use ExUnit.Case

  @simpler_replacements [
    H: [:H, :O],
    H: [:O, :H],
    O: [:H, :H],
  ]

  test "the simple case" do
    result =
      "HOH"
      |> Chem.string_to_atoms
      |> Chem.generate_replacements(@simpler_replacements)
    IO.inspect result
    assert length(result) == 4
    assert Enum.member?(result, "HOOH")
    assert Enum.member?(result, "HOHO")
    assert Enum.member?(result, "OHOH")
    assert Enum.member?(result, "HHHH")
  end

  @tag :skip
  test "another simple case" do
    result =
      "HOHOHO"
      |> Chem.string_to_atoms
      |> Chem.generate_replacements(@simpler_replacements)
    assert length(result) == 7
  end

end

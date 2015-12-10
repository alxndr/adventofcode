defmodule LookAndSay do

  # http://www.se16.info/js/lands2.htm
  @mapping [
    U:  ["3", [:Pa]],
    Pa: ["13", [:Th]],
    Th: ["1113", [:Ac]],
    Ac: ["3113", [:Ra]],
    Ra: ["132113", [:Fr]],
    Fr: ["1113122113", [:Rn]],
    Rn: ["311311222113", [:Ho, :At]],
    At: ["1322113", [:Po]],
    Po: ["1113222113", [:Bi]],
    Bi: ["3113322113", [:Pm, :Pb]],
    Pb: ["123222113", [:Tl]],
    Tl: ["111213322113", [:Hg]],
    Hg: ["31121123222113", [:Au]],
    Au: ["132112211213322113", [:Pt]],
    Pt: ["111312212221121123222113", [:Ir]],
    Ir: ["3113112211322112211213322113", [:Os]],
    Os: ["1321132122211322212221121123222113", [:Re]],
    Re: ["111312211312113221133211322112211213322113", [:Ge, :Ca, :W]],
    W:  ["312211322212221121123222113", [:Ta]],
    Ta: ["13112221133211322112211213322113", [:Hf, :Pa, :H, :Ca, :W]],
    Hf: ["11132", [:Lu]],
    Lu: ["311312", [:Yb]],
    Yb: ["1321131112", [:Tm]],
    Tm: ["11131221133112", [:Er, :Ca, :Co]],
    Er: ["311311222", [:Ho, :Pm]],
    Ho: ["1321132", [:Dy]],
    Dy: ["111312211312", [:Tb]],
    Tb: ["3113112221131112", [:Ho, :Gd]],
    Gd: ["13221133112", [:Eu, :Ca, :Co]],
    Eu: ["1113222", [:Sm]],
    Sm: ["311332", [:Pm, :Ca, :Zn]],
    Pm: ["132", [:Nd]],
    Nd: ["111312", [:Pr]],
    Pr: ["31131112", [:Ce]],
    Ce: ["1321133112", [:La, :H, :Ca, :Co]],
    La: ["11131", [:Ba]],
    Ba: ["311311", [:Cs]],
    Cs: ["13211321", [:Xe]],
    Xe: ["11131221131211", [:I]],
    I:  ["311311222113111221", [:Ho, :Te]],
    Te: ["1322113312211", [:Eu, :Ca, :Sb]],
    Sb: ["3112221", [:Pm, :Sn]],
    Sn: ["13211", [:In]],
    In: ["11131221", [:Cd]],
    Cd: ["3113112211", [:Ag]],
    Ag: ["132113212221", [:Pd]],
    Pd: ["111312211312113211", [:Rh]],
    Rh: ["311311222113111221131221", [:Ho, :Ru]],
    Ru: ["132211331222113112211", [:Eu, :Ca, :Tc]],
    Tc: ["311322113212221", [:Mo]],
    Mo: ["13211322211312113211", [:Nb]],
    Nb: ["1113122113322113111221131221", [:Er, :Zr]],
    Zr: ["12322211331222113112211", [:Y, :H, :Ca, :Tc]],
    Y:  ["1112133", [:Sr, :U]],
    Sr: ["3112112", [:Rb]],
    Rb: ["1321122112", [:Kr]],
    Kr: ["11131221222112", [:Br]],
    Br: ["3113112211322112", [:Se]],
    Se: ["13211321222113222112", [:As]],
    As: ["11131221131211322113322112", [:Ge, :Na]],
    Ge: ["31131122211311122113222", [:Ho, :Ga]],
    Ga: ["13221133122211332", [:Eu, :Ca, :Ac, :H, :Ca, :Zn]],
    Zn: ["312", [:Cu]],
    Cu: ["131112", [:Ni]],
    Ni: ["11133112", [:Zn, :Co]],
    Co: ["32112", [:Fe]],
    Fe: ["13122112", [:Mn]],
    Mn: ["111311222112", [:Cr, :Si]],
    Cr: ["31132", [:V]],
    V:  ["13211312", [:Ti]],
    Ti: ["11131221131112", [:Sc]],
    Sc: ["3113112221133112", [:Ho, :Pa, :H, :Ca, :Co]],
    Ca: ["12", [:K]],
    K:  ["1112", [:Ar]],
    Ar: ["3112", [:Cl]],
    Cl: ["132112", [:S]],
    S:  ["1113122112", [:P]],
    P:  ["311311222112", [:Ho, :Si]],
    Si: ["1322112", [:Al]],
    Al: ["1113222112", [:Mg]],
    Mg: ["3113322112", [:Pm, :Na]],
    Na: ["123222112", [:Ne]],
    Ne: ["111213322112", [:F]],
    F:  ["31121123222112", [:O]],
    O:  ["132112211213322112", [:N]],
    N:  ["111312212221121123222112", [:C]],
    C:  ["3113112211322112211213322112", [:B]],
    B:  ["1321132122211322212221121123222112", [:Be]],
    Be: ["111312211312113221133211322112211213322112", [:Ge, :Ca, :Li]],
    Li: ["312211322212221121123222112", [:He]],
    He: ["13112221133211322112211213322112", [:Hf, :Pa, :H, :Ca, :Li]],
    H:  ["22", [:H]],
  ]

  @mapping
  |> Enum.each(fn ({ element, [string, evolution] }) ->
    def evolve(unquote(element)), do: unquote(evolution)
    def identify(unquote(string)), do: unquote(element)
    def to_numstr(unquote(element)), do: unquote(string)
  end)

  def find_nth_generation(e, 0), do: e # 0 generations not supported
  def find_nth_generation(element_str, num_generations) when is_binary(element_str) do
    element_str
    |> identify
    |> find_nth_generation(num_generations)
  end
  def find_nth_generation(element, num_generations) when is_atom(element) do
    (0..num_generations - 1)
    |> Enum.reduce([element], fn (_n, generation) ->
      Enum.flat_map(generation, &evolve/1)
    end)
  end

  def elems_to_numstr(elements) do
    elements
    |> Enum.reduce("", fn(elem, acc) -> acc <> LookAndSay.to_numstr(elem) end)
  end

end

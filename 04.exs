defmodule A do

  @search_space_start 1
  @search_space_end 9999999

  def f(str), do: f(str, @search_space_start)
  def f(_str, n) when n < @search_space_start or n > @search_space_end, do: nil
  def f(str, n) do
    if is_the_thing?(str, n) do
      IO.puts "yeah! #{str} ... #{n}"
      n
    else
      f str, n+1
    end
  end

  defp is_the_thing?(str, n) do
    :crypto.hash(:md5, "#{str}#{n}")
    |> starts_with_zeroes?
  end

  defp starts_with_zeroes?(<<0, 0, m, _::binary>>) when m == 0, do: true
  defp starts_with_zeroes?(_), do: false

end

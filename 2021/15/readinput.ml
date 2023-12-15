#load "str.cma"

let contents file =
  match file
  with
    | "-" -> In_channel.input_all In_channel.stdin
    | file -> In_channel.with_open_bin file In_channel.input_all

let lines file =
  contents file
    |> String.split_on_char '\n'

let empty_regexp =
  Str.regexp {||}

let arr_of_arrs file =
  lines file
    |> List.map (fun line ->
        Str.split empty_regexp line)

#use "readinput.ml"

let () =
  print_endline "\n... v0.1.0 ...\n"

let matrix =
  arr_of_arrs "sample-small.txt"

let () =
  matrix
  |> List.map (fun chars -> String.concat "." chars)
  |> String.concat "\n"
  |> print_endline

let rec get_ list n =
  match list with
  | [] -> []
  | _  -> match n with
    | 0 -> let head::_ = list in head
    | n -> get_ list (n - 1)

let val_at = fun (a, b) ->
  get_ (get_ matrix a) b

let () =
  (val_at matrix (1, 1)) (* should print out 3... *)
  |> print_endline

open Core;;
open Unix;;
open String_extensions;;

let use_non_canonical_input () =
  let terminfo = UnixLabels.tcgetattr stdin in
  let newterminfo = { terminfo with c_icanon = false; c_vmin = 0; c_vtime = 0} in
  at_exit (fun _ -> UnixLabels.tcsetattr stdin ~mode:UnixLabels.TCSAFLUSH terminfo); (* reset channel when quitting program *)
  UnixLabels.tcsetattr stdin ~mode:UnixLabels.TCSAFLUSH newterminfo;;
      
let clear_current_line line_string output_channel =
  Out_channel.output_char output_channel '\r';
  Out_channel.output_string output_channel
    (String.repeat_char (String.length line_string + 10) ' ');
  Out_channel.output_char output_channel '\r';
  Out_channel.flush output_channel;;

let run input_channel =
  use_non_canonical_input ();
  let output = Out_channel.stdout in
  (* f (current_input:char list) (history:string array) (history_ptr:int) *)
  let rec f (): char list -> string array -> int -> unit = 
    match In_channel.input_char input_channel with
        | Some '\n' -> (fun current_input history _ ->
            print_endline "";
            let line = (String.of_char_list_rev current_input) in
            (match line with
                | ":q" -> print_endline "Goodbye!";
                | _ -> print_endline line;
                    f() [] (Array.of_list (line::(Array.to_list history))) (-1);
            );)
        | Some c -> (fun current_input ->
          (match Char.to_int c with
            | 127 (*Backspace*) ->
              Out_channel.output_string output "\b\b\b   \b\b\b";
              Out_channel.flush output;
              f() (Option.value (List.tl current_input) ~default:[]);
            | 27 (* Special character *) -> second_special_character() current_input;
            | c_int -> Out_channel.output_string output (Int.to_string c_int);
              if String.equal (Int.to_string c_int) "279165" then print_endline "UP_PRESSED" else print_endline "NOT_UP";
              Out_channel.flush output;
              f() (c::current_input);));
        | None -> f();
(* second_special_character (current_input:char list) (history:string array) (history_ptr:int) *)
and second_special_character (): char list -> string array -> int -> unit =
    match In_channel.input_char input_channel with
    | Some '[' -> final_special_character()
    | Some _ -> let _ = In_channel.input_char input_channel in f()
    | None -> second_special_character();
(* final_special_character (current_input:char list) (history:string array) (history_ptr:int) *)
and final_special_character (): char list -> string array -> int -> unit =
    match In_channel.input_char input_channel with
    | Some 'A' (* Up key *) -> fun current_input history history_ptr ->
        let new_history_ptr = history_ptr + 1 in
        if new_history_ptr < (Array.length history) then
          (clear_current_line (String.of_char_list_rev current_input) output;
           let history_val = (Array.get history new_history_ptr) in
           Out_channel.output_string output history_val;
           Out_channel.flush output;
           f() (String.to_list history_val) history new_history_ptr;)
        else
          (clear_current_line (String.of_char_list_rev current_input) output;
           Out_channel.output_string output (String.of_char_list current_input);
           Out_channel.flush output;
          f() current_input history history_ptr;)
    | Some 'B' (* Down key *) -> fun current_input history history_ptr ->
      let new_history_ptr = history_ptr - 1 in
      if new_history_ptr >= 0 then
        (clear_current_line (String.of_char_list_rev current_input) output;
         let history_val = (Array.get history new_history_ptr) in
         Out_channel.output_string output history_val;
         Out_channel.flush output;
         f() (String.to_list history_val) history new_history_ptr;)
      else
        (clear_current_line (String.of_char_list_rev current_input) output;
         Out_channel.output_string output (String.of_char_list current_input);
         Out_channel.flush output;
         f() current_input history history_ptr;)
    | Some 'C' (* Right key *) -> fun current_input ->
      (clear_current_line (String.of_char_list current_input) output;
       Out_channel.output_string output (String.of_char_list current_input);
       Out_channel.flush output;
       f() current_input;)
    | Some 'D' (* Left key *) -> fun current_input ->
      (clear_current_line (String.of_char_list current_input) output;
       Out_channel.output_string output (String.of_char_list current_input);
       Out_channel.flush output;
       f() current_input;)
    | Some _ -> f()
    | None -> final_special_character() in
  f() [] (Array.create ~len:0 "") (-1);;

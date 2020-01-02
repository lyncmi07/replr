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
  let rec f (character_consumer : int -> char list -> string array -> int -> unit) : char list -> string array -> int -> unit =
    match In_channel.input_char input_channel with
        | Some c -> character_consumer (Char.to_int c);
        | None -> f character_consumer;
  (* default_character (current_input:char list) (history:string array) (history_ptr:int) *)
  and default_character (c:int) : char list -> string array -> int -> unit = (fun current_input -> match c with
            | 10 (*Newline*) -> fun history _ ->
                print_endline "";
                let line = (String.of_char_list_rev current_input) in
                (match line with
                    | ":q" -> print_endline "Goodbye!";
                    | _ -> print_endline line;
                        f default_character [] (Array.of_list (line::(Array.to_list history))) (-1);
                );
            | 127 (*Backspace*) ->
              Out_channel.output_string output "\b\b\b   \b\b\b";
              Out_channel.flush output;
              f default_character (Option.value (List.tl current_input) ~default:[]);
            | 27 (* Special character *) -> f second_special_character current_input;
            | c_int -> Out_channel.output_string output (Int.to_string c_int);
              if String.equal (Int.to_string c_int) "279165" then print_endline "UP_PRESSED" else print_endline "NOT_UP";
              Out_channel.flush output;
              f default_character ((Char.unsafe_of_int c)::current_input););
(* second_special_character (current_input:char list) (history:string array) (history_ptr:int) *)
and second_special_character : int -> char list -> string array -> int -> unit = function
        | 91 (*[*) -> f final_special_character
        | _ -> let _ = In_channel.input_char input_channel in f default_character
(* final_special_character (current_input:char list) (history:string array) (history_ptr:int) *)
and final_special_character (c:int): char list -> string array -> int -> unit = (fun current_input -> match c with
      | 65 (*Up arrow*) -> fun history history_ptr ->
          let new_history_ptr = history_ptr + 1 in
          if new_history_ptr < (Array.length history) then
            (clear_current_line (String.of_char_list_rev current_input) output;
            let history_val = (Array.get history new_history_ptr) in
            Out_channel.output_string output history_val;
            Out_channel.flush output;
            f default_character (String.to_list history_val) history new_history_ptr;)
          else
            (clear_current_line (String.of_char_list_rev current_input) output;
            Out_channel.output_string output (String.of_char_list current_input);
            Out_channel.flush output;
            f default_character current_input history history_ptr;)
      | 66 (*Down arrow*) -> fun history history_ptr ->
          let new_history_ptr = history_ptr - 1 in
          if new_history_ptr >= 0 then
            (clear_current_line (String.of_char_list_rev current_input) output;
            let history_val = (Array.get history new_history_ptr) in
            Out_channel.output_string output history_val;
            Out_channel.flush output;
            f default_character (String.to_list history_val) history new_history_ptr;)
          else
            (clear_current_line (String.of_char_list_rev current_input) output;
            Out_channel.output_string output (String.of_char_list current_input);
            Out_channel.flush output;
            f default_character current_input history history_ptr;)
      | 67 (*Right arrow*) -> 
          (clear_current_line (String.of_char_list current_input) output;
          Out_channel.output_string output (String.of_char_list current_input);
          Out_channel.flush output;
          f default_character current_input;)
      | 68 (*Left arrow*) ->
          (clear_current_line (String.of_char_list current_input) output;
          Out_channel.output_string output (String.of_char_list current_input);
          Out_channel.flush output;
          f default_character current_input;)
      | _ -> f default_character current_input) in
  f default_character [] (Array.create ~len:0 "") (-1);;

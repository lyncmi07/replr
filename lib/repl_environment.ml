open Core;;
open Unix;;

let use_non_canonical_input () =
  let terminfo = UnixLabels.tcgetattr stdin in
  let newterminfo = { terminfo with c_icanon = false; c_vmin = 0; c_vtime = 0} in
  at_exit (fun _ -> UnixLabels.tcsetattr stdin ~mode:UnixLabels.TCSAFLUSH terminfo); (* reset channel when quitting program *)
  UnixLabels.tcsetattr stdin ~mode:UnixLabels.TCSAFLUSH newterminfo;;

let run input_channel =
  let build_string char_list = String.rev (String.of_char_list char_list) in
  use_non_canonical_input ();
  let output = Out_channel.stdout in
  let rec f current_input =
      match In_channel.input_char input_channel with
        | Some '\n' -> print_endline "";
            let line = (build_string current_input) in
            (match line with
                | ":q" -> print_endline "Goodbye!";
                | _ -> print_endline line;
                   f [];)
        | Some 'b' -> Out_channel.output_char output '\r';
          Out_channel.output_string output "overwriting";
          Out_channel.flush output;
          f current_input;
        | Some c -> f (c::current_input);
        | None -> f current_input in
  f []

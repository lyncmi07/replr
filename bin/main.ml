open Core;;
open Replr;;

match (Array.length Sys.argv) with
| 0 -> 
    print_endline "No config file has been specified";
| _ -> 

let config_file = In_channel.create Sys.argv.(1) in
try
    let config = Config.parse_config (In_channel.input_all config_file) in
    (match List.hd (Config.template config) with
    | Some template1 -> print_endline template1
    | None -> print_endline "Template empty");
    let input = In_channel.input_all In_channel.stdin in
    let filled_template = Config.fill_template config input in
    let src_file = Out_channel.create (Config.source_filename config) in
    Out_channel.output_string src_file filled_template;
    Out_channel.close src_file;

    let compile_exec = Unix.create_process ~prog:(Config.compile_command config) ~args:(Config.compile_args config) in
    let compile_output = Unix.in_channel_of_descr compile_exec.stderr in
    print_endline (In_channel.input_all compile_output);

    let execute_exec = Unix.create_process ~prog:(Config.execute_command config) ~args:(Config.execute_args config) in
    let execute_output = Unix.in_channel_of_descr execute_exec.stdout in
    print_endline (In_channel.input_all execute_output);
with e ->
    In_channel.close config_file;
    raise e;;

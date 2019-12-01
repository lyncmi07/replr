open Core;;
open Replr;;

match (Array.length Sys.argv) with
| 0 -> 
    print_endline "No config file has been specified";
| _ -> 

let config_file = In_channel.create Sys.argv.(1) in
try
    let config = Config.parse_config (In_channel.input_all config_file) in
    match config with
    | (_, a, _, _, _) -> print_endline a;
    print_endline "HELLO WORLD";
with e ->
    In_channel.close config_file;
    raise e;;

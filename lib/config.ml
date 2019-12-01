open Core;;
open String_extensions;;

type repl_type_t = Shbang | Repl;;
type config_t = repl_type_t * string * string * string * string * string list;;

let repl_type = fun (r, _, _, _, _, _) -> r;;
let base_name = fun (_, b, _, _, _, _) -> b;;
let source_extension = fun (_, _, s, _, _, _) -> s;;
let compiler = fun (_, _, _, c, _, _) -> c;;
let executor = fun (_, _, _, _, e, _) -> e;;
let template = fun (_, _, _, _, _, t) -> t;;

let source_filename c = ((base_name c) ^ (source_extension c));;

let compile_full_command c = String.split_on_string (String.substr_replace_all (compiler c) ~pattern:"<%%>" ~with_:(base_name c)) " ";;
let compile_command c = match compile_full_command c with
    | [] -> raise (Invalid_argument ("Compile command '" ^ (compiler c) ^ "' is invalid"));
    | x::_ -> x;;
let compile_args c = match compile_full_command c with
    | [] -> raise (Invalid_argument ("Compile command '" ^ (compiler c) ^ "' is invalid"));
    | _::xs -> xs;;

let execute_full_command c = String.split_on_string (String.substr_replace_all (executor c) ~pattern:"<%%>" ~with_:(base_name c)) " ";;
let execute_command c = match execute_full_command c with
    | [] -> raise (Invalid_argument ("Compile command '" ^ (executor c) ^ "' is invalid"));
    | x::_ -> x;;
let execute_args c = match execute_full_command c with
    | [] -> raise (Invalid_argument ("Compile command '" ^ (executor c) ^ "' is invalid"));
    | _::xs -> xs;;

let fill_template c fill =
    let separated_fill = String.split_on_string fill "<%%>" in
    let rec f template fill result = match template with
        | [] -> List.rev result
        | x::xs -> (match fill with
                    | [] -> f xs [] (x::result)
                    | y::ys -> f xs ys (y::x::result)) in
    String.concat (f (template c) separated_fill []);;

let parse_template template_string = String.split_on_string template_string "<%%>";;

let parse_config config_data =
    let config_lines = String.split_lines config_data in
    match config_lines with
    | repl_type::base_name::source_extension::compile::run::_::template ->
            (
                (match (String.drop_prefix repl_type (String.length "type:")) with
                | "shbang" -> Shbang
                | "repl" -> Repl
                | _ -> raise (Invalid_argument ("Invalid repl type set in config file: " ^ repl_type))),
                String.drop_prefix base_name (String.length "base_name:"),
                String.drop_prefix source_extension (String.length "source_extension:"),
                String.drop_prefix compile (String.length "compile:"),
                String.drop_prefix run (String.length "run:"),
                parse_template (String.concat template)
            )
    | _ -> raise (Invalid_argument "Invalid config file format");;


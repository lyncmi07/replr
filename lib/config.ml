open Core

type repl_type_t = Shbang | Repl
type config_t = repl_type_t * string * string * string * string list

module String =
    struct
        include Core.String;;
        let split_on_string str on = [str; on];;
    end

module Config =
    struct
        let repl_type = fun (r, _, _, _, _) -> r;;
        let base_name = fun (_, b, _, _, _) -> b;;
        let compiler = fun (_, _, c, _, _) -> c;;
        let executor = fun (_, _, _, e, _) -> e;;
        let template = fun (_, _, _, _, t) -> t;;
    end

let parse_template template_string = 
    let rec remove_empty template_lines = match template_lines with
    | [] -> []
    | (x::xs) -> match x with
        | "" -> remove_empty xs
        | _ -> x::(remove_empty xs) in
    remove_empty (String.split_on_string template_string "<%%>");;

let parse_config config_data =
    let config_lines = String.split_lines config_data in
    match config_lines with
    | repl_type::base_name::compile::run::_::template ->
            (
                (*match repl_type with
                | "shbang" -> Shbang
                | "repl" -> Repl,*)
                (match (String.drop_prefix repl_type (String.length "type:")) with
                | "shbang" -> Shbang
                | "repl" -> Repl
                | _ -> raise (Invalid_argument ("Invalid repl type set in config file: " ^ repl_type))),
                String.drop_prefix base_name (String.length "base_name:"),
                String.drop_prefix compile (String.length "compile:"),
                String.drop_prefix run (String.length "run:"),
                parse_template (String.concat template)
            )
    | _ -> raise (Invalid_argument "Invalid config file format");;


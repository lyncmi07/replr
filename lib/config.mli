type repl_type_t = Shbang | Repl;;
type config_t = repl_type_t * string * string * string * string * string list;;

val repl_type : config_t -> repl_type_t
val base_name : config_t -> string
val source_extension : config_t -> string
val compiler : config_t -> string
val executor : config_t -> string
val template : config_t -> string list

val source_filename : config_t -> string

val compile_command : config_t -> string
val compile_args : config_t -> string list

val execute_command : config_t -> string
val execute_args : config_t -> string list

val fill_template : config_t -> string -> string

val parse_config : string -> config_t;;

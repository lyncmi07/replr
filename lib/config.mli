type repl_type_t = Shbang | Repl
type config_t = repl_type_t * string * string * string * string list

module Config :
    sig

        val repl_type : config_t -> repl_type_t
        val base_name : config_t -> string
        val compiler : config_t -> string
        val executor : config_t -> string
        val template : config_t -> string list
    end;;

val parse_config : string -> config_t

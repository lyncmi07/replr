open Core;;

module String =
    struct
        include Core.String;;
        let split_on_string (str:string) (on:string):string list=
            let on_char = to_list on in
            let rec f (original:char list) (current:char list) (on_found:char list) (on_left:char list) (result:string list):string list =
              match original with
                | [] -> List.rev ((of_char_list (List.rev current))::result);
                | x::xs -> (match on_left with
                        | [] -> f original [] [] on_char ((of_char_list (List.rev current))::result);
                        | y::ys -> if phys_equal x y 
                            then f xs current (y::on_found) ys result
                            else let new_current = x::(List.rev ((List.rev current) @ on_found)) in
                                f xs new_current [] on_char result); in
              f (to_list str) [] [] on_char [];;
        let of_char_list_rev (li:char list) = rev (of_char_list li);;
        let repeat_char (n:int) (c:char) = of_char_list (Array.to_list (Array.create ~len:n c));;
    end;;

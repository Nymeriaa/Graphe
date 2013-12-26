
type 'a arc = 'a * 'a ;;
type 'a graph = ('a list) array ;;
type 'a graph_valued = (('a * int) list) array ;;
exception Close_Node 
exception Empty_Graph

let is_not_visited (node : 'a) tab_VNV  : bool = tab_VNV.(node) ;;

(* 
 * return true if the node got more than one neighbor who's not visited 
 *)

let got_neighbor_nv (x : 'a) (graph_succ : 'a graph) tab_VNV  : bool =
  let list_nodes_adj = graph_succ.(x) in
  let rec aux liste tab_VNV = 
    if liste = []
    then false
    else ( if (is_not_visited (List.hd liste) tab_VNV)
           then true
           else (aux (List.tl liste) tab_VNV) )
  in
    (aux list_nodes_adj tab_VNV) ;;

(*
 * return the first node not visited in the node adjacent list of "n"
 *)

let choose_neighbor_nv (n : int) (graph_succ : 'a graph) tab_VNV : 'a =
  let liste = graph_succ.(n) in
  let rec aux = function liste -> function tab_VNV ->
    if liste = [] 
    then raise Close_Node
    else ( match (is_not_visited (List.hd liste) tab_VNV) with
           | true -> (List.hd liste)
           | _    -> (aux (List.tl liste) tab_VNV) )
  in
    (aux liste tab_VNV) ;; 

(*
 * look over all the nodes while find one who's not yet visited 
 *)

let rec choose_node_nv tab_VNV (graph_succ : 'a graph) (node : int) : 'a =
  if node = (Array.length graph_succ) then -1
  else ( if (is_not_visited node tab_VNV) 
         then node 
         else (choose_node_nv tab_VNV graph_succ (node + 1)) ) ;;

let rec delete_elem_from_lst (elem : int) (lst : 'a list) (graph : 'a graph) 
: unit =
  if lst = []
  then ()
  else (let x = List.hd lst in
          graph.(x) <- (List.filter (fun e -> e <> elem) graph.(x)) ; 
          delete_elem_from_lst elem (List.tl lst) graph) ;;

let choose_less_pred (graph_pred : int graph) (graph_succ : int graph) 
: (int * int graph) =
  let length = Array.length graph_pred in
  let new_graph_pred = Array.copy graph_pred in
  let aux = Array.make length 0 in 
  for i = 0 to (length - 1) do 
    if graph_pred.(i) = [-1] 
    then aux.(i) <- 100 (* +∞ *)
    else aux.(i) <- List.length graph_pred.(i)
  done ;
  let i = ref 0 in
  while (!i < length) && (aux.(!i) <> 0) do
    i := 1 + (!i)
  done ;
  let _ = if (!i = length) then raise Empty_Graph in
  let lst_succ = graph_succ.(!i) in 
  let _ = delete_elem_from_lst (!i) lst_succ new_graph_pred in
  let _ = new_graph_pred.(!i) <- [-1] in
    (!i, new_graph_pred) ;;

(*
 * They can't be circuit
 *)

let rec construct_list_topo (graph_pred : int graph) (graph_succ : int graph) 
(lst : int list) : int list =
  try
  let (s, graph_pred) = choose_less_pred graph_pred graph_succ in
    (construct_list_topo graph_pred graph_succ (s::lst)) 
  with Empty_Graph -> lst 

let rec get_lst_arc (graph : 'a graph_valued) (index : int) : ('a * 'a * int) list =
  if index >= Array.length graph 
  then []
  else (List.append (List.map (fun (x, c) -> (index, x, c)) graph.(index)) 
                    (get_lst_arc graph (index + 1))) ;;

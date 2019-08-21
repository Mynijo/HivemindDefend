extends Node

var a_star_map : AStar

const FLOOR_DOWN = Vector3(0,-1,0)

enum { e_FRONT_BACK = 1, e_RIGHT_LEFT = 2, e_BACK_FRONT = 3, e_LEFT_RIGHT = 4}
enum { e_FRONT = 1, e_RIGHT = 2, e_BACK = 3, e_LEFT = 4}

func _ready():
    a_star_map = AStar.new()

func _input(event):
    if event.is_action_pressed("Debug_input"):
        init_map(creat_test_map())    
        var test = a_star_map.get_point_path(pos_to_id(Vector3(0,0,0)),pos_to_id(Vector3(7,0,7)))       
        pass

func creat_test_map() -> Dictionary:
    var temp_map : Dictionary
    temp_map[Vector3(1,0,0)] = 0
    temp_map[Vector3(2,0,0)] = 0
    temp_map[Vector3(3,0,0)] = 0
    temp_map[Vector3(8,0,0)] = 0
    temp_map[Vector3(5,0,5)] = 0
    temp_map[Vector3(6,0,5)] = 0
    temp_map[Vector3(5,0,7)] = 0
    temp_map[Vector3(6,0,7)] = 0
    temp_map[Vector3(7,0,7)] = 0
    temp_map[Vector3(1,0,9)] = 0
    temp_map[Vector3(2,0,9)] = 0
    temp_map[Vector3(3,0,9)] = 0
    temp_map[Vector3(4,0,9)] = 0
    temp_map[Vector3(5,0,9)] = 0
    temp_map[Vector3(6,0,9)] = 0
    temp_map[Vector3(7,0,9)] = 0
    temp_map[Vector3(8,0,9)] = 0
    temp_map[Vector3(0,0,0)] = 0
    temp_map[Vector3(0,0,1)] = 0
    temp_map[Vector3(0,0,2)] = 0
    temp_map[Vector3(0,0,3)] = 0
    temp_map[Vector3(0,0,4)] = 0
    temp_map[Vector3(0,0,5)] = 0
    temp_map[Vector3(0,0,6)] = 0
    temp_map[Vector3(0,0,7)] = 0
    temp_map[Vector3(0,0,8)] = 0
    temp_map[Vector3(0,0,9)] = 0
    temp_map[Vector3(2,0,2)] = 0
    temp_map[Vector3(2,0,3)] = 0
    temp_map[Vector3(2,0,4)] = 0
    temp_map[Vector3(2,0,5)] = 0
    temp_map[Vector3(2,0,6)] = 0
    temp_map[Vector3(2,0,7)] = 0
    temp_map[Vector3(2,0,8)] = 0
    temp_map[Vector3(4,0,0)] = 0
    temp_map[Vector3(4,0,1)] = 0
    temp_map[Vector3(4,0,2)] = 0
    temp_map[Vector3(4,0,3)] = 0
    temp_map[Vector3(4,0,4)] = 0
    temp_map[Vector3(4,0,5)] = 0
    temp_map[Vector3(4,0,6)] = 0
    temp_map[Vector3(4,0,7)] = 0
    temp_map[Vector3(7,0,0)] = 0
    temp_map[Vector3(7,0,1)] = 0
    temp_map[Vector3(7,0,2)] = 0
    temp_map[Vector3(7,0,3)] = 0
    temp_map[Vector3(7,0,4)] = 0
    temp_map[Vector3(7,0,5)] = 0
    temp_map[Vector3(9,0,0)] = 0
    temp_map[Vector3(9,0,1)] = 0
    temp_map[Vector3(9,0,2)] = 0
    temp_map[Vector3(9,0,3)] = 0
    temp_map[Vector3(9,0,4)] = 0
    temp_map[Vector3(9,0,5)] = 0
    temp_map[Vector3(9,0,6)] = 0
    temp_map[Vector3(9,0,7)] = 0
    temp_map[Vector3(9,0,8)] = 0
    temp_map[Vector3(9,0,9)] = 0    
    return temp_map


func init_map(var map_dict : Dictionary):
    a_star_map.clear()
    var i : int = 0
    for key in map_dict:
        a_star_map.add_point(pos_to_id(key),key)
        for neighbour in get_valid_neighbours(key, map_dict):
            if a_star_map.has_point(pos_to_id(neighbour)):
                if not a_star_map.are_points_connected(pos_to_id(neighbour), pos_to_id(key)):
                    a_star_map.connect_points(pos_to_id(neighbour), pos_to_id(key))
    pass
        
func get_valid_neighbours(var pos : Vector3, var map_dict : Dictionary) -> Array:
    var temp_valid_neighbours : Array
    temp_valid_neighbours.clear()
    var temp_pos_neighbours : Dictionary
    
    temp_pos_neighbours[e_FRONT] = pos + Vector3(1,0,0)
    temp_pos_neighbours[e_BACK]  = pos + Vector3(-1,0,0)
    temp_pos_neighbours[e_RIGHT] = pos + Vector3(0,0,1)
    temp_pos_neighbours[e_LEFT]  = pos + Vector3(0,0,-1)
    
    for key in temp_pos_neighbours:
        if map_dict.has(temp_pos_neighbours[key]):
            if map_dict.get(temp_pos_neighbours[key]) == 0:
                if not map_dict.has(temp_pos_neighbours[key] + FLOOR_DOWN):                    
                    temp_valid_neighbours.append(temp_pos_neighbours[key])
                elif map_dict.get(temp_pos_neighbours[key] + FLOOR_DOWN) != 0:
                    if is_node_ramp_connectable(map_dict.get(temp_pos_neighbours[key] + FLOOR_DOWN),key, false):
                        temp_valid_neighbours.append(temp_pos_neighbours[key])
            else: # check ramp
                if is_node_ramp_connectable(map_dict.get(temp_pos_neighbours[key]), temp_pos_neighbours[key]):
                    temp_valid_neighbours.append(temp_pos_neighbours[key])    
    return temp_valid_neighbours
        
func is_node_ramp_connectable(var ramp_dirc, var block_pos_relativ, var same_floor = true) -> bool:
    if same_floor:
        if block_pos_relativ == e_FRONT and ramp_dirc == e_FRONT_BACK:
            return true
        if block_pos_relativ == e_RIGHT and ramp_dirc == e_RIGHT_LEFT:
            return true
        if block_pos_relativ == e_BACK  and ramp_dirc == e_BACK_FRONT:
            return true
        if block_pos_relativ == e_LEFT  and ramp_dirc == e_LEFT_RIGHT:
            return true
    else:
        if block_pos_relativ == e_FRONT and ramp_dirc == e_BACK_FRONT:
            return true
        if block_pos_relativ == e_RIGHT and ramp_dirc == e_LEFT_RIGHT:
            return true
        if block_pos_relativ == e_BACK  and ramp_dirc == e_FRONT_BACK:
            return true
        if block_pos_relativ == e_LEFT  and ramp_dirc == e_RIGHT_LEFT:
            return true
    return false
        
func pos_to_id(var pos : Vector3) -> int:
    return int(pos.x * 100000 + pos.y * 100 + pos.z)
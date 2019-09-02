extends Node

var a_star_map : AStar

const FLOOR_DOWN = Vector3(0,-1,0)

enum { e_FRONT_BACK = 1, e_RIGHT_LEFT = 2, e_BACK_FRONT = 3, e_LEFT_RIGHT = 4}
# enum { e_FRONT = 1, e_RIGHT = 2, e_BACK = 3, e_LEFT = 4}

const EAST = Vector3(1, 0, 0)
const WEST = Vector3(-1, 0, 0)
const NORTH = Vector3(0, 0, -1)
const SOUTH = Vector3(0, 0, 1)
const UP = Vector3(0, -1, 0)
const DOWN = Vector3(0, 1, 0)

var max_map_size : Vector3

func _ready():
    a_star_map = AStar.new()
    self.connect("map_generated", self, "_init_map")

func _input(event):
    if event.is_action_pressed("Debug_input"):
        _init_map(null)
        var test = a_star_map.get_point_path(pos_to_id(Vector3(0,0,0)),pos_to_id(Vector3(7,0,7)))
        pass

func create_test_map() -> Dictionary:
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


func _init_map(var map):
    var map_dict : Dictionary
    if map == null: #test map
        map_dict = create_test_map()
        max_map_size = Vector3(100,100,100)
    else:
        map_dict = map.get_active_nods()
        max_map_size = map.get_size()

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

    for key in [EAST, WEST, NORTH, SOUTH]:
        if map_dict.has(pos + key):
            if map_dict.get(pos + key) == 0:
                if not map_dict.has(pos + key + FLOOR_DOWN):
                    temp_valid_neighbours.append(pos + key)
                elif map_dict.get(pos + key + FLOOR_DOWN) != 0:
                    if is_node_ramp_connectable(map_dict.get(pos + key + FLOOR_DOWN),key, false):
                        temp_valid_neighbours.append(pos + key)
            else: # check ramp
                if is_node_ramp_connectable(map_dict.get(pos + key), pos + key):
                    temp_valid_neighbours.append(pos + key)
    return temp_valid_neighbours

func is_node_ramp_connectable(var ramp_dirc, var block_pos_relativ, var same_floor = true) -> bool:
    if same_floor:
        if block_pos_relativ == SOUTH and ramp_dirc == e_FRONT_BACK:
            return true
        if block_pos_relativ == EAST and ramp_dirc == e_RIGHT_LEFT:
            return true
        if block_pos_relativ == NORTH  and ramp_dirc == e_BACK_FRONT:
            return true
        if block_pos_relativ == WEST  and ramp_dirc == e_LEFT_RIGHT:
            return true
    else:
        if block_pos_relativ == SOUTH and ramp_dirc == e_BACK_FRONT:
            return true
        if block_pos_relativ == EAST and ramp_dirc == e_LEFT_RIGHT:
            return true
        if block_pos_relativ == NORTH  and ramp_dirc == e_FRONT_BACK:
            return true
        if block_pos_relativ == WEST  and ramp_dirc == e_RIGHT_LEFT:
            return true
    return false

func pos_to_id(var pos : Vector3) -> int:
    #return int(pos.x * 10000000 + pos.y * 1000 + pos.z)
    return int(pos.x * max_map_size.y * max_map_size.z  + pos.y * max_map_size.z + pos.z)
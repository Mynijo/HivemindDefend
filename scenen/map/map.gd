extends Spatial

const MapNode = preload("res://scenen/map/map_node.gd")

export (bool) var fog_of_war_flag = true

var map_nodes = []
var map_size : Vector3

var map_floor_root_nodes = []

func _init():
    pass

func _ready():
    pass

func gen_map_with_file(var Map_generation_file_path = "res://scenen/map/map_generation_config.json"):
    map_nodes = $MapGenerator.generate_map(Map_generation_file_path)
    map_size = get_map_size()
    add_nodes_to_tree()
    activate_nodes()

func add_nodes_to_tree():
    for y in range(map_size.y):
        var node = Spatial.new()
        node.name = str("Floor_", y)
        map_floor_root_nodes.append(weakref(node))
        for x in range(map_size.x):
            for z in range(map_size.z):
                node.add_child(map_nodes[x][y][z])
        add_child(node)
        show_floor(y)

# Only use tis if chain_activate from block can hit more than 1000blocks
# Only activate_nodes that are connected to floor 0 with tran blocks
func activate_nodes():
    var found_tran_node = false
    for y in range(map_size.y):
        found_tran_node = false
        for x in range(map_size.x):
            for z in range(map_size.z):
                if get_map_node(Vector3(x,y,z)).is_transparent():
                    found_tran_node = true
                for n in get_node_neighbours(Vector3(x,y,z), true):
                    if n.is_transparent():
                        get_map_node(Vector3(x,y,z)).activate()
                        break
        if not found_tran_node:
            return

func get_map_node(Position : Vector3) -> MapNode:
    if Position.x < 0 or Position.x >= map_size.x or \
       Position.y < 0 or Position.y >= map_size.y or \
       Position.z < 0 or Position.z >= map_size.z:
        return null
    return map_nodes[Position.x][Position.y][Position.z]

func hide_floor(floor_number : int):
    map_floor_root_nodes[floor_number].get_ref().hide()

func show_floor(floor_number : int):
    map_floor_root_nodes[floor_number].get_ref().show()

func set_map_nodes(var Map_nodes):
    map_nodes = Map_nodes

func activate_node(Pos : Vector3):
    var node : MapNode = get_map_node(Pos)
    if node.active == true:
        return
    node.activate()

func deactivate_node(Pos : Vector3):
    var node : MapNode = get_map_node(Pos)
    node.deactivate()

func replace_node_Static_game_object(Pos : Vector3,  Static_game_object : class_StaticGameObject):
    get_map_node(Pos).set_static_game_object(Static_game_object)
    if Static_game_object.transparent:
        for neighbour in get_node_neighbours(Pos):
            activate_node(neighbour.get_position())

func get_node_neighbours(Node_pos : Vector3, ignor_floor :  bool = false) -> Array:
    var neighbours = []
    if get_map_node(Node_pos + Vector3(-1,0,0)):
        neighbours.append(get_map_node(Node_pos + Vector3(-1,0,0)))
    if get_map_node(Node_pos + Vector3(0,0,-1)):
        neighbours.append(get_map_node(Node_pos + Vector3(0,0,-1)))
    if get_map_node(Node_pos + Vector3(1,0,0)):
        neighbours.append(get_map_node(Node_pos + Vector3(1,0,0)))
    if get_map_node(Node_pos + Vector3(0,1,0)) and not ignor_floor:
        neighbours.append(get_map_node(Node_pos + Vector3(0,1,0)))
    if get_map_node(Node_pos + Vector3(0,0,1)):
        neighbours.append(get_map_node(Node_pos + Vector3(0,0,1)))
    if get_map_node(Node_pos + Vector3(0,-1,0)):
        neighbours.append(get_map_node(Node_pos + Vector3(0,-1,0)))
    return neighbours

func get_active_node_neighbours(Node_pos : Vector3) -> Array:
    var active_neighbours = []
    var neighbours = get_node_neighbours(Node_pos)
    for node in neighbours:
        if node.active:
            active_neighbours.append(node)
    return active_neighbours

func get_not_active_nodes_neighbour(Node_pos : Vector3) -> Array:
    var not_active_neighbours = []
    var neighbours = get_node_neighbours(Node_pos)
    for node in neighbours:
        if not node.active:
            not_active_neighbours.append(node)
    return not_active_neighbours

func get_map_size() -> Vector3:
    return Vector3(map_nodes.size(),map_nodes[0].size(),map_nodes[0][0].size())

func save() -> Dictionary:
    var save_node_array : Array = []
    for x in map_nodes:
        for y in x:
            for node in y:
                save_node_array.append(node.save_to_dict())
    var save_node_dict : Dictionary ={
        "map_size" : [map_size.x, map_size.y, map_size.z],
        "map_nodes" : save_node_array
    }
    var save_map_dict : Dictionary ={
        "filename" : get_filename(),
        "parent" : get_parent().get_path(),
        "data": save_node_dict
    }
    return save_map_dict

func load_game(data : Dictionary):
    var map_size_array = data["map_size"]
    map_size = Vector3(map_size_array[0],map_size_array[1],map_size_array[2])
    var test = data["map_nodes"]
    map_nodes = $MapGenerator.generate_node_map_from_dirc(map_size, data["map_nodes"])
    add_nodes_to_tree()

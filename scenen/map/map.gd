extends Spatial
class_name class_map, "res://scenen/map/map.gd"

const Map_generator = preload("res://scenen/map/map_generation.gd")
onready var map_generator = Map_generator.new()

export (String) var map_generation_file_path = "res://scenen/map/map_generation_config.json"
export (bool) var fog_of_war_flag = true

var map_nodes = []
var map_fog_of_war_nodes = []

var map_size : Vector3

func _ready():
    map_nodes = map_generator.generate_map(map_generation_file_path)  
    map_size = get_map_size()
    print("init_map_fog_of_war_nodes start")
    init_map_fog_of_war_nodes(map_size)  
    print("init_map_fog_of_war_nodes done")
    
    var counter = 0
    for x in map_nodes:
        for y in x:
            for z in y:
                counter += 1
                if counter % 10000 == 0:
                    print("Checked Blocks:",counter)
                var pos : Vector3 = z.get_position()
                var neighbours = get_node_neighbours(pos)
                for node in neighbours:
                    if node.is_transparent() or pos.y == 0 or not fog_of_war_flag: #remove later
                        activate_node(pos)
                        break
    pass
  
func init_map_fog_of_war_nodes(map_size : Vector3):
    var class_map_node = load("res://scenen/static_game_object/static_game_object_unknown.tscn")
    map_fog_of_war_nodes.resize(map_size.x)
    var fog_of_war_nodes_root = self.get_node("fog_of_war_nodes")
    self.remove_child(fog_of_war_nodes_root)
    for x in map_size.x:
        map_fog_of_war_nodes[x] = []
        map_fog_of_war_nodes[x].resize(map_size.y)    # Y-dimension
        for y in map_size.y:
            map_fog_of_war_nodes[x][y] = []
            map_fog_of_war_nodes[x][y].resize(map_size.z)    # Z-dimension
            for z in map_size.z:
                var temp_node = class_map_node.instance()
                temp_node.translation = Vector3(x,y *-1,z)
                map_fog_of_war_nodes[x][y][z] = temp_node
                fog_of_war_nodes_root.add_child(temp_node)
    self.add_child(fog_of_war_nodes_root)
                                
func get_map_node(Position : Vector3) -> class_map_node:
    var map_size : Vector3 = get_map_size()
    if Position.x < 0 or Position.x >= map_size.x or \
       Position.y < 0 or Position.y >= map_size.y or \
       Position.z < 0 or Position.z >= map_size.z:
        return null        
    return map_nodes[Position.x][Position.y][Position.z]
    
func get_map_fog_of_war_node(Position : Vector3) -> class_map_node:
    var map_size : Vector3 = get_map_size()
    if Position.x < 0 or Position.x >= map_size.x or \
       Position.y < 0 or Position.y >= map_size.y or \
       Position.z < 0 or Position.z >= map_size.z:
        return null        
    return map_fog_of_war_nodes[Position.x][Position.y][Position.z]
   
func set_map_nodes(var Map_nodes):
    map_nodes = Map_nodes
    
func activate_node(Pos : Vector3):
    var node : class_map_node = get_map_node(Pos)
    if node.active == true:
        return
    node.active = true
    self.get_node("active_nodes").add_child(node)
    self.get_node("fog_of_war_nodes").remove_child(get_map_fog_of_war_node(Pos))
     
func deactivate_node(Pos : Vector3):
    var node : class_map_node = get_map_node(Pos)
    node.active = false
    self.get_node("active_nodes").remove_child(node)
    self.get_node("fog_of_war_nodes").add_child(get_map_fog_of_war_node(Pos))
    
func replace_node_Static_game_object(Pos : Vector3,  Static_game_object : class_StaticGameObject):
    get_map_node(Pos).set_static_game_object(Static_game_object)
    if Static_game_object.transparent:
        for neighbour in get_node_neighbours(Pos):
            activate_node(neighbour.get_position())
    
func get_node_neighbours(Node_pos : Vector3) -> Array:
    var neighbours = []
    if get_map_node(Node_pos + Vector3(-1,0,0)):
        neighbours.append(get_map_node(Node_pos + Vector3(-1,0,0)))
    if get_map_node(Node_pos + Vector3(0,-1,0)):
        neighbours.append(get_map_node(Node_pos + Vector3(0,-1,0)))
    if get_map_node(Node_pos + Vector3(0,0,-1)):
        neighbours.append(get_map_node(Node_pos + Vector3(0,0,-1)))
    if get_map_node(Node_pos + Vector3(1,0,0)):
        neighbours.append(get_map_node(Node_pos + Vector3(1,0,0)))
    if get_map_node(Node_pos + Vector3(0,1,0)):
        neighbours.append(get_map_node(Node_pos + Vector3(0,1,0)))
    if get_map_node(Node_pos + Vector3(0,0,1)):
        neighbours.append(get_map_node(Node_pos + Vector3(0,0,1)))    
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
  
func get_active_nodes() -> Array:
    var active_nodes = self.get_node("active_nodes").get_children()    
    return active_nodes
      
func get_map_size() -> Vector3:
    return Vector3(map_nodes.size(),map_nodes[0].size(),map_nodes[0][0].size())
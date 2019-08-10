extends Spatial
class_name class_map, "res://scenen/map/map.gd"

var map_generator

export (bool) var fog_of_war_flag = true

var map_nodes = []

var map_size : Vector3

func _init():
    var class_map_generator = preload("res://scenen/map/map_generation.gd")
    map_generator = class_map_generator.new()

func _ready():
    pass

func gen_map_with_file(var Map_generation_file_path = "res://scenen/map/map_generation_config.json"):
    map_nodes = map_generator.generate_map(Map_generation_file_path)  
    map_size = get_map_size()
    aply_nodes()
    pass
    
func aply_nodes():    
    var counter = 0
    for x in map_nodes:
        for y in x:
            for z in y:
                add_child(z)
                counter += 1
                if counter % 10000 == 0:
                    print("Checked Blocks:",counter)
                var pos : Vector3 = z.get_position()
                var neighbours = get_node_neighbours(pos)
                for node in neighbours:
                    if node.is_transparent() or pos.y == 0 or not fog_of_war_flag: #remove later
                        activate_node(pos)
                        break
                               
func get_map_node(Position : Vector3) -> class_map_node:
    var map_size : Vector3 = get_map_size()
    if Position.x < 0 or Position.x >= map_size.x or \
       Position.y < 0 or Position.y >= map_size.y or \
       Position.z < 0 or Position.z >= map_size.z:
        return null        
    return map_nodes[Position.x][Position.y][Position.z]
    
   
func set_map_nodes(var Map_nodes):
    map_nodes = Map_nodes
    
func activate_node(Pos : Vector3):
    var node : class_map_node = get_map_node(Pos)
    if node.active == true:
        return
    node.activate()
     
func deactivate_node(Pos : Vector3):
    var node : class_map_node = get_map_node(Pos)
    node.deactivate()
    
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
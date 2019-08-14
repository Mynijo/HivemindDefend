extends Spatial
class_name class_map_node, "res://scenen/map/map_node.gd"

var static_game_object_unknown_path= "res://scenen/static_game_object/static_game_object_unknown.tscn"

var static_game_object_path : String =""

var static_game_object : class_StaticGameObject = null
var static_game_object_unknown : class_StaticGameObject = null
export (Vector3) var position = Vector3(-1,-1,-1)

var active = false

func _init():
    static_game_object_unknown = resource_manager.get_resource(static_game_object_unknown_path).instance()
    add_child(static_game_object_unknown)

func set_static_game_object_path( var path):
    static_game_object_path = path

func is_active() -> bool:
    return active

func set_static_game_object( var Static_game_object): #: class_StaticGameObject ):
    if static_game_object:
        Static_game_object.queue_free()
    if active:
        self.add_child(Static_game_object)
    static_game_object = Static_game_object

func activate():
    if not active:
        static_game_object_unknown.hide()
        if not static_game_object and static_game_object_path:
            static_game_object = resource_manager.get_resource(static_game_object_path).instance()    
        self.add_child(static_game_object)
        active = true
    
func deactivate():
    if active:
        if not static_game_object_unknown and static_game_object_unknown_path:
            static_game_object_unknown = resource_manager.get_resource(static_game_object_unknown_path).instance()        
        self.add_child(static_game_object_unknown)
        self.remove_child(static_game_object)
        static_game_object.queue_free()
        active = false
        
      
func start_activate_chain(var Map, var Rec_counter = 0):
    if active :
        return
    if  Rec_counter >= 800: # after 1000 the game crash
        print("allmost died in start_activate_chain")
        return
    Rec_counter += 1
    activate()
    if is_transparent():
        for n in Map.get_node_neighbours(position):  
            n.start_activate_chain(Map, Rec_counter)
    
func get_static_game_object() -> class_StaticGameObject:
    return static_game_object
    
func set_position(Pos : Vector3):
    self.translation = Pos * Vector3(1,-1,1)
    position = Pos

func get_position() -> Vector3:
    return position
        
func get_object_path() -> String:
    if not static_game_object_path:
        if get_static_game_object():
            return get_static_game_object().get_filename()
    return static_game_object_path
    
func is_transparent() -> bool:
    var trans : bool = false     
    if not static_game_object and static_game_object_path:
        var temp_static_game_object = resource_manager.get_resource(static_game_object_path).instance()    
        trans = temp_static_game_object.transparent
        temp_static_game_object.free()
    elif static_game_object:
        trans = static_game_object.transparent
    return trans
    
func save_to_dict()->Dictionary:
    var path : String = get_object_path()
    var pos = get_position()
    var save_node_dict : Dictionary ={
        "object_path" : path,
        "node_position" : [pos.x, pos.y, pos.z],
        "node_active" : is_active(),
    } 
    return save_node_dict
    
func load_from_dict(Data_dict : Dictionary):
    if Data_dict.has("object_path"):
        set_static_game_object_path(Data_dict.get("object_path"))
    if Data_dict.has("node_position"):
        set_position(Vector3(Data_dict.get("node_position")[0], \
                             Data_dict.get("node_position")[1], \
                             Data_dict.get("node_position")[2]))    
    if Data_dict.has("node_active"):
        if Data_dict.get("node_active"):
            activate()
    
    
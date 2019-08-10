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

func set_static_game_object( var Static_game_object): #: class_StaticGameObject ):
    if static_game_object:
        Static_game_object.queue_free()
    if active:
        self.add_child(Static_game_object)
    static_game_object = Static_game_object

func activate():
    if not active:
        self.remove_child(static_game_object_unknown)
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
        active = false
    
func get_static_game_object() -> class_StaticGameObject:
    return static_game_object
    
func set_position(Pos : Vector3):
    self.translation = Pos * Vector3(1,-1,1)
    position = Pos

func get_position() -> Vector3:
    return position
        
func get_object_path() -> String:
    return static_game_object_path
    
func is_transparent() -> bool:
    if static_game_object:
        return static_game_object.transparent
    return true
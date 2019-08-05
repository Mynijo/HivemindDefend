extends Spatial
class_name class_map_node, "res://scenen/map/map_node.gd"


var static_game_object : class_StaticGameObject = null
export (Vector3) var position = Vector3(-1,-1,-1)

var active = false

func set_static_game_object( var Static_game_object): #: class_StaticGameObject ):
    self.add_child(Static_game_object)
    static_game_object = Static_game_object

func get_static_game_object() -> class_StaticGameObject:
    return static_game_object
    
func set_position(Pos : Vector3):
    position = Pos

func get_position() -> Vector3:
    return position
    
func is_transparent() -> bool:
    if static_game_object:
        return static_game_object.transparent
    return true
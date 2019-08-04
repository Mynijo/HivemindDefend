extends Spatial
class_name class_StaticGameObject, "res://scenen/static_game_object/static_game_object.gd"

const Map_generator = preload("res://scenen/map/map_generation.gd")
onready var map_generator = Map_generator.new()

var map = []

func _ready():
    map = map_generator.generate_map("res://scenen/map/map_generation_config.json")
    for x in map:
        for y in x:
            for z in y:
                if z:
                    self.add_child(z)
                                
func get_map_node(position : Vector3) -> class_StaticGameObject:
    return map[position.x][position.y][position.z]
    
func set_map(var Map):
    map = Map
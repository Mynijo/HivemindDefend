extends Spatial
class_name class_StaticGameObject, "res://scenen/StaticGameObject/StaticGameObject.gd"

const Map_generator = preload("res://scenen/map/map_generation.gd")
onready var map_generator = Map_generator.new()

var map = []

func _ready():
    map = map_generator.generate_map("res://scenen/map/map_generation_config.json")
                
func ini_map(map_size : Vector3):
    for x in range(map_size.x):
        map[x].append([])
        for y in range(map_size.y):
            map[x][y].append([])
            for z in range(map_size.z):
                map[x][y][z].append(null)
                
func get_map_node(position : Vector3) -> class_StaticGameObject:
    return map[position.x][position.y][position.z]
    
func set_map(var Map):
    map = Map
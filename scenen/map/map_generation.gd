class_name class_map, "res://scenen/map/map.gd"

var temp_map =  []
var map_config

func generate_map(path) -> Array:
    var class_map_generation_config = load("res://scenen/map/map_generation_config.gd")
    var map_config_generator = class_map_generation_config.new()
    map_config = map_config_generator.generate_config_with_json(path)
    return temp_map
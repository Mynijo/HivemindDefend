export (String) var name = "default_name"
export (Vector2) var map_size = Vector2(42,42)

var map_areas #= [map_area.new()]

class map_area:
    var name = "default_name"
    var floor_range = Vector2(5,5)
    var default_static_game_object  = ""
    var special_static_game_objects = [null]
    

class class_special_static_game_object:    
    var path = ""
    var spawn_chance = 0
    var spawn_range = Vector2(0,0) # -1 = no limit
    var value_range = Vector2(0,0)
    


func generate_config_with_json(var path) -> Object:
    var config = load_json(path)
    
    if config.has("name"):
        name = config.get("name")
    if config.has("map_size"):
        map_size = config.get("map_size")    
    if config.has("map_areas"):
        map_areas = load_map_areas_jsonResult(config.get("map_areas"))
    return self

func load_map_areas_jsonResult(jsonResult : Array) -> Array:
    var temp_map_areas = []
    for area in jsonResult:
        var temp_map_area = map_area.new()
        if area.has("name"):
            temp_map_area.name = area.get("name")
        if area.has("floor_range"):
            temp_map_area.floor_range =area.get("floor_range")
        if area.has("default_static_game_object"):
            temp_map_area.default_static_game_object = area.get("default_static_game_object")               
        if area.has("special_static_game_objects"):
            temp_map_area.special_static_game_objects = load_special_game_objects_jsonResult(area.get("special_static_game_objects"))
        temp_map_areas.append(temp_map_area) 
    return temp_map_areas
    
func load_special_game_objects_jsonResult(jsonResult : Array) -> Array:
    var temp_special_game_objects = []
    for object in jsonResult:
        var temp_special_game_object = class_special_static_game_object.new()
        if object.has("path"):
            temp_special_game_object.path = object.get("path")
        if object.has("spawn_chance"):
            temp_special_game_object.spawn_chance = object.get("spawn_chance")
        if object.has("spawn_range"):
            temp_special_game_object.spawn_range = object.get("spawn_range")
        if object.has("value_range"):
            temp_special_game_object.value_range = object.get("value_range")
        temp_special_game_objects.append(temp_special_game_object)  
    return temp_special_game_objects
     
   
func load_json(var path) -> JSONParseResult:
    var file = File.new()
    file.open(path, file.READ)
    var config = parse_json(file.get_as_text()) 
    file.close()      
    return config
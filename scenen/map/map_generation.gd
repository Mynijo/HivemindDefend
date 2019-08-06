extends Spatial

var rng = RandomNumberGenerator.new()

var temp_map =  []
var temp_name_map =  []
var map_config
var map_size : Vector3

func _ready():
    rng.randomize()

export (String) var bedrock = "res://scenen/static_game_object/blocks/block_bedrock.tscn"
export (String) var top_air = "res://scenen/static_game_object/static_game_object_top_air.tscn"

func ini_maps():
    var class_map_node = load("res://scenen/map/map_node.tscn")
    var map_node = class_map_node.instance() 
    temp_map.resize(map_size.x)    # X-dimension
    temp_name_map.resize(map_size.x)
    for x in map_size.x:
        temp_map[x] = []
        temp_map[x].resize(map_size.y)    # Y-dimension
        temp_name_map[x] = []
        temp_name_map[x].resize(map_size.y)    # Y-dimension
        for y in map_size.y:
            temp_map[x][y] = []
            temp_map[x][y].resize(map_size.z)    # Z-dimension
            temp_name_map[x][y] = []
            temp_name_map[x][y].resize(map_size.z)    # Z-dimension
            for z in map_size.z:
                temp_map[x][y][z] = map_node.duplicate()

func generate_map(path) -> Array:
    var class_map_generation_config = load("res://scenen/map/map_generation_config.gd")
    var map_config_generator = class_map_generation_config.new()
    map_config = map_config_generator.generate_config_with_json(path)
    roll_ranges(map_config)
    ini_maps()
    generate_temp_name_map(map_config)
    generate_temp_map()
    return temp_map

      
func generate_temp_name_map_border():
    for x in range(map_size.x):
        for y in range(map_size.y):
            temp_name_map[x][y][0] = bedrock
            temp_name_map[x][y][map_size.z -1] = bedrock            
    for z in range(map_size.z):
        for y in range(map_size.y):
            temp_name_map[0][y][z] = bedrock
            temp_name_map[map_size.x -1][y][z] = bedrock
    for x in range(map_size.x):
        for z in range(map_size.z):
            temp_name_map[x][0][z] = top_air
            temp_name_map[x][map_size.y-1][z] = bedrock
                    
func roll_ranges(map_config : class_map_generation_config):
    rng.randomize()
    
    map_size = Vector3(0,0,0)
    map_size.x = map_config.map_size[0] +2 #border +2
    map_size.z = map_config.map_size[1] +2 #border +2
    map_size.y += 2#border +2
    for area in map_config.map_areas:
        area.rolled_floor_range = rng.randi_range(area.floor_range[0], area.floor_range[1])
        map_size.y += area.rolled_floor_range
        for game_object in area.special_static_game_objects:
            game_object.rolled_spawn_range = rng.randi_range(game_object.spawn_range[0], game_object.spawn_range[1])
           
func generate_temp_map(): 
    for x in range(map_size.x):
        for y in range(map_size.y):
            for z in range(map_size.z):
                var node = temp_name_map[x][y][z]
                if node:
                    var class_block = load(node)
                    var temp_block = class_block.instance()
                    temp_block.translation = Vector3(x,y *-1,z)
                    temp_map[x][y][z].set_position(Vector3(x,y,z))
                    temp_map[x][y][z].set_static_game_object(temp_block)

func generate_temp_name_map(var map_config):   
    var areas = []
    var floor_count = 0 +1#top air
    for area in map_config.map_areas:
        areas.append(generate_temp_name_map_area(area,floor_count))
        floor_count += area.rolled_floor_range
    generate_temp_name_map_border()  
            
func generate_temp_name_map_area(var Map_area, var Start_floor):
    var blocks = []
    var area_block_count = (map_size.x -2) * (map_size.z -2) * Map_area.rolled_floor_range    
    for object in Map_area.special_static_game_objects:
        for i in range(object.rolled_spawn_range):
            blocks.append(object.path)    
    for i in range(area_block_count - blocks.size()):
        blocks.append(Map_area.default_static_game_object)
    
    randomize()
    blocks.shuffle()
    var temp_block_counter = area_block_count
    for x in range(map_size.x -2):
        for y in range(Map_area.rolled_floor_range):
            for z in range(map_size.z -2):
                temp_block_counter -= 1
                temp_name_map[x+1][y+Start_floor][z+1] =  blocks[temp_block_counter]
                
    
    
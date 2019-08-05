extends Spatial



var rng = RandomNumberGenerator.new()

var temp_map =  []
var temp_name_map =  []
var map_config
var map_size = Vector3(0,0,0)


func _ready():
    rng.randomize()

export (String) var bedrock = "res://scenen/static_game_object/blocks/block_bedrock.tscn"
export (String) var top_air = "res://scenen/static_game_object/static_game_object_top_air.tscn"

func ini_maps(var map_config):
    var deeps = 2 # +1 for bedrock floor +1 for air cap
    var class_map_node = load("res://scenen/map/map_node.tscn")
    var map_node = class_map_node.instance()
    for area in map_config.map_areas:
        area.actual_range = rng.randi_range(area.floor_range[0], area.floor_range[1])   
        deeps += area.actual_range
    map_size = Vector3( map_config.map_size[0],deeps,map_config.map_size[1])    
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
    ini_maps(map_config)
    generate_temp_name_map(map_config)
    generate_temp_map(map_config)
    return temp_map


 
func generate_temp_name_map(var map_config):   
    for area in map_config.map_areas:
        for x in range(map_size.x):
            for y in range(map_size.y):
                for z in range(map_size.z):
                    temp_name_map[x][y][z] = area.default_static_game_object                
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
            
            
func generate_temp_map(var map_config): 
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
        

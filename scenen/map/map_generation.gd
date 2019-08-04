extends Spatial
class_name class_map, "res://scenen/map/map.gd"

var rng = RandomNumberGenerator.new()

var temp_map =  []
var temp_name_map =  []
var map_config
var map_size = Vector3(0,0,0)


func _ready():
    rng.randomize()

export (String) var bedrock = "res://scenen/static_game_object/blocks/block_bedrock.tscn"

func ini_maps(var map_config):
    var deeps = 0
    for area in map_config.map_areas:
        area.actual_range = rng.randi_range(area.floor_range[0], area.floor_range[1])   
        deeps += area.actual_range
    map_size = Vector3( map_config.map_size[0] +2,deeps,map_config.map_size[1] +2)    
    temp_map.resize(map_size.x)    # X-dimension
    for x in map_size.x:
        temp_map[x] = []
        temp_map[x].resize(map_size.y)    # Y-dimension
        for y in map_size.y:
            temp_map[x][y] = []
            temp_map[x][y].resize(map_size.z)    # Z-dimension
    temp_name_map = temp_map.duplicate()
                

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
            
func generate_temp_map(var map_config): 
    for x in range(map_size.x):
        for y in range(map_size.y):
            for z in range(map_size.z):
                var node = temp_name_map[x][y][z]
                if node:
                    var class_block = load(node)
                    var temp_block = class_block.instance()
                    temp_block.translation = Vector3(x,y *-1,z)
                    temp_map[x][y][z] = temp_block
    
    
        
     
func generate_name_map_area(map_config : Dictionary):
    pass
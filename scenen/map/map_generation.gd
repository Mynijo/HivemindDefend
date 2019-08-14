

const MapNode = preload("res://scenen/map/map_node.gd")
const MapGenerationConfig = preload("res://scenen/map/map_generation_config.gd")

var rng = RandomNumberGenerator.new()
var map_config

func _ready():
    rng.randomize()

export (String) var bedrock = "res://scenen/static_game_object/blocks/block_bedrock.tscn"
export (String) var top_air = "res://scenen/static_game_object/static_game_object_top_air.tscn"

#export (String) var bedrock = "res://scenen/static_game_object/static_game_object_top_air.tscn"
#export (String) var top_air = "res://scenen/static_game_object/blocks/block_bedrock.tscn"

func ini_map(var Map_size : Vector3) -> Array:
    var temp_map = []
    temp_map.resize(Map_size.x)    # X-dimension
    for x in Map_size.x:
        temp_map[x] = []
        temp_map[x].resize(Map_size.y)    # Y-dimension
        for y in Map_size.y:
            temp_map[x][y] = []
            temp_map[x][y].resize(Map_size.z)    # Z-dimension
            for z in Map_size.z:
                temp_map[x][y][z] = MapNode.new()
                temp_map[x][y][z].set_position(Vector3(x,y,z))
    return temp_map

func generate_map(path) -> Array:
    var map_config_generator = MapGenerationConfig.new()
    map_config = map_config_generator.generate_config_with_json(path)
    var map_size = roll_ranges(map_config)
    var temp_map = generate_node_map(map_size, map_config)
    return temp_map


func roll_ranges(map_config : MapGenerationConfig) -> Vector3:
    rng.randomize()

    var map_size : Vector3= Vector3(0,0,0)
    map_size.x = map_config.map_size[0] +2 #border +2
    map_size.z = map_config.map_size[1] +2 #border +2
    map_size.y += 2#border +2
    for area in map_config.map_areas:
        area.rolled_floor_range = rng.randi_range(area.floor_range[0], area.floor_range[1])
        map_size.y += area.rolled_floor_range
        for game_object in area.special_static_game_objects:
            game_object.rolled_spawn_range = rng.randi_range(game_object.spawn_range[0], game_object.spawn_range[1])
    return map_size

func generate_node_map(var Map_size, var map_config) -> Array:   
    var temp_map = ini_map(Map_size)    
    var floor_count = 0 +1#top air
    for area in map_config.map_areas:
        generate_temp_name_map_area(Map_size, area,floor_count, temp_map)
        floor_count += area.rolled_floor_range
    generate_temp_name_map_border(Map_size, temp_map)
    return temp_map

func generate_node_map_from_dirc(var Map_size : Vector3, Map_nodes_data : Array) -> Array:   
    var temp_map = ini_map(Map_size)
    generate_temp_name_map_from_dirc(Map_size, temp_map, Map_nodes_data)  
    return temp_map

func generate_temp_name_map_area(var Map_size,var Map_area, var Start_floor, var Temp_map):
    var blocks = []
    var area_block_count = (Map_size.x -2) * (Map_size.z -2) * Map_area.rolled_floor_range

    #add scene
    for scene in Map_area.map_scenes:
        if scene.path:
            var node_map_scene = resource_manager.get_resource(scene.path)
            var temp_node_map_scene = node_map_scene.instance()
            var game_objects = temp_node_map_scene.get_node("static_game_object").get_children()
            if game_objects:
                var temp_aabb : AABB = AABB(game_objects[0].get_position(), Vector3(0,0,0))
                for game_object in game_objects:
                    temp_aabb = temp_aabb.expand(game_object.get_position())
                var scene_pos_min : Vector3 = temp_aabb.get_endpoint(2)
                var scene_size : Vector3 = temp_aabb.size +Vector3(1,1,1)
                if Map_size.x -2 > scene_size.x and \
                   Map_area.rolled_floor_range >= scene_size.y and \
                   Map_size.z -2 > scene_size.z:
                    rng.randomize()
                    if not Map_size.x -2 > scene_size.x + scene.spawn_pos_range_min.x:
                        scene.spawn_pos_range_min.x = Map_size.x -2 - scene_size.x
                    if not Map_area.rolled_floor_range >= scene_size.y + scene.spawn_pos_range_min.y:
                        scene.spawn_pos_range_min.y = Map_area.rolled_floor_range - scene_size.y
                    if not Map_size.z -2 > scene_size.z + scene.spawn_pos_range_min.z:
                        scene.spawn_pos_range_min.z = Map_size.z -2 - scene_size.z

                    if not Map_size.x -2 > scene_size.x + scene.spawn_pos_range_max.x or scene.spawn_pos_range_max.x == -1:
                        scene.spawn_pos_range_max.x = Map_size.x -2 - scene_size.x
                    if not Map_area.rolled_floor_range >= scene_size.y + scene.spawn_pos_range_max.y or scene.spawn_pos_range_max.y == -1:
                        scene.spawn_pos_range_max.y = Map_area.rolled_floor_range - scene_size.y
                    if not Map_size.z -2 > scene_size.z + scene.spawn_pos_range_max.z or scene.spawn_pos_range_max.z == -1:
                        scene.spawn_pos_range_max.z = Map_size.z -2 - scene_size.z

                    var sceen_rolled_start_pos : Vector3  = Vector3(rng.randi_range(scene.spawn_pos_range_min.x,scene.spawn_pos_range_max.x), \
                                                                    rng.randi_range(scene.spawn_pos_range_min.y,scene.spawn_pos_range_max.y), \
                                                                    rng.randi_range(scene.spawn_pos_range_min.z,scene.spawn_pos_range_max.z))
                    sceen_rolled_start_pos += Vector3(1,Start_floor,1) # border
                    for game_object in game_objects:
                        var game_object_pos = (game_object.get_position() - scene_pos_min) * Vector3(1,-1,1) + sceen_rolled_start_pos
                        var node = Temp_map[game_object_pos.x][game_object_pos.y][game_object_pos.z]
                        if not node.get_static_game_object():
                            node.set_static_game_object(game_object.duplicate())
                            node.get_static_game_object().set_position(Vector3(0,0,0)) #reset locan pos
                            area_block_count -= 1
                        else:
                            print("conflict at", game_object_pos)
                            game_object.free()
            temp_node_map_scene.free()

    #add singel special_static_game_objects
    if Map_area.special_static_game_objects:
        for object in Map_area.special_static_game_objects:
            for i in range(object.rolled_spawn_range):
                blocks.append(object.path)
    # Fill area with default
    for i in range(area_block_count - blocks.size()):
        blocks.append(Map_area.default_static_game_object)

    randomize()
    blocks.shuffle()
    var temp_block_counter = area_block_count
    for x in range(Map_size.x -2):
        for y in range(Map_area.rolled_floor_range):
            for z in range(Map_size.z -2):
                if not Temp_map[x+1][y+Start_floor][z+1].get_static_game_object():
                    temp_block_counter -= 1
                    Temp_map[x+1][y+Start_floor][z+1].set_static_game_object_path(blocks[temp_block_counter])
                else:
                    pass
    if temp_block_counter != 0:
        print("ERROR: ",temp_block_counter ," BLocks left! <--------")

func generate_temp_name_map_border(var Map_size, var Temp_name_map):
    for x in range(Map_size.x):
        for y in range(Map_size.y):
            Temp_name_map[x][y][0].set_static_game_object_path(bedrock)
            Temp_name_map[x][y][Map_size.z -1].set_static_game_object_path(bedrock)
    for z in range(Map_size.z):
        for y in range(Map_size.y):
            Temp_name_map[0][y][z].set_static_game_object_path(bedrock)
            Temp_name_map[Map_size.x -1][y][z].set_static_game_object_path(bedrock)
    for x in range(Map_size.x):
        for z in range(Map_size.z):
            Temp_name_map[x][0][z].set_static_game_object_path(top_air)
            Temp_name_map[x][Map_size.y-1][z].set_static_game_object_path(bedrock)

func generate_temp_name_map_from_dirc(var Map_size, var Temp_map, Map_nodes_data : Array):
    for node_dirc in Map_nodes_data:
        Temp_map[node_dirc["node_position"][0]] \
                [node_dirc["node_position"][1]] \
                [node_dirc["node_position"][2]] \
                    .load_from_dict(node_dirc)

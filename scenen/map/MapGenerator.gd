extends Node

export (String) var default_map_name = "New Map"
export (Vector2) var default_map_size = Vector2(20, 20)

const DEFAULT_BLOCK = "Dirt"
const BLOCK_BEDROCK = "Bedrock"
const BLOCK_TOP_AIR = "TopAir"

const ORIENTATION_ARRAY = [
        Basis(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)),
        Basis(Vector3(0, -1, 0), Vector3(1, 0, 0), Vector3(0, 0, 1)),
        Basis(Vector3(-1, 0, 0), Vector3(0, -1, 0), Vector3(0, 0, 1)),
        Basis(Vector3(0, 1, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1)),
        Basis(Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, 1, 0)),
        Basis(Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(0, 1, 0)),
        Basis(Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 0)),
        Basis(Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(0, 1, 0)),
        Basis(Vector3(1, 0, 0), Vector3(0, -1, 0), Vector3(0, 0, -1)),
        Basis(Vector3(0, 1, 0), Vector3(1, 0, 0), Vector3(0, 0, -1)),
        Basis(Vector3(-1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, -1)),
        Basis(Vector3(0, -1, 0), Vector3(-1, 0, 0), Vector3(0, 0, -1)),
        Basis(Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, -1, 0)),
        Basis(Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(0, -1, 0)),
        Basis(Vector3(-1, 0, 0), Vector3(0, 0, -1), Vector3(0, -1, 0)),
        Basis(Vector3(0, 0, 1), Vector3(-1, 0, 0), Vector3(0, -1, 0)),
        Basis(Vector3(0, 0, 1), Vector3(0, 1, 0), Vector3(-1, 0, 0)),
        Basis(Vector3(0, -1, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0)),
        Basis(Vector3(0, 0, -1), Vector3(0, -1, 0), Vector3(-1, 0, 0)),
        Basis(Vector3(0, 1, 0), Vector3(0, 0, -1), Vector3(-1, 0, 0)),
        Basis(Vector3(0, 0, 1), Vector3(0, -1, 0), Vector3(1, 0, 0)),
        Basis(Vector3(0, 1, 0), Vector3(0, 0, 1), Vector3(1, 0, 0)),
        Basis(Vector3(0, 0, -1), Vector3(0, 1, 0), Vector3(1, 0, 0)),
        Basis(Vector3(0, -1, 0), Vector3(0, 0, -1), Vector3(1, 0, 0))
    ]

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
    self.rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

const BOTTOM_BORDER : Dictionary = {
    default_block = BLOCK_BEDROCK
    }

const TOP_AIR_BORDER : Dictionary = {
    default_block = BLOCK_TOP_AIR
    }

const DEFAULT_CONTENTS : Dictionary = {
    map_area = {
        name = "New Area",
        floor_range = Vector2(5, 5),
        rolled_floor_range = -1,
        default_block  = DEFAULT_BLOCK,
        special_blocks = [],
        map_scenes = []
        },
    special_block = {
        block = DEFAULT_BLOCK,
        spawn_chance = 0,
        spawn_range = Vector2(0, 0), # -1 = no limit
        rolled_spawn_range = -1
        },
    map_scene = {
        path = "",
        rotation_range = Vector2(0, 0),
        spawn_pos_range_min = Vector3(0, 0, 0),    # ( 0, 0, 0) = dont care
        spawn_pos_range_max = Vector3(-1, -1, -1)  # (-1,-1,-1) = dont care
        }
    }


func generate_map(map_generation_file_path : String) -> Dictionary:
    var config = self._load_config(map_generation_file_path)
    var map_size = config["map_size"]
    var special_map_nodes = {}
    var map_nodes = {}
    var block : String
    var default_block : String = DEFAULT_BLOCK
    var num_floors : int
    var current_floor = 0
    var scene_map : Dictionary
    var bbox : AABB
    var free_points : Array
    var num_special_blocks : int
    var node : Dictionary
    for map_area in [TOP_AIR_BORDER] + config["map_areas"] + [BOTTOM_BORDER]:
        num_floors = self._roll_range(map_area.get("floor_range", Vector2(1, 1)))
        bbox = AABB(Vector3(1, current_floor, 1), Vector3(map_size.x, num_floors, map_size.y))  # Total current box
        for scene in map_area.get("map_scenes", []):
            scene_map = self._put_scene_into_bbox(scene, bbox)
            for vindex in scene_map:
                special_map_nodes[vindex] = scene_map[vindex]
        free_points = self._get_all_points_in_bbox(bbox, special_map_nodes.keys())
        free_points.shuffle()
        for special_blocks in map_area.get("special_blocks", []):
            num_special_blocks = 0
            for i in range(num_floors):
                num_special_blocks += self._roll_range(special_blocks.get("spawn_range", Vector2(0, 0)))
            block = special_blocks["block"]
            node = {
                active = false,
                block = block
                }
            while free_points and num_special_blocks > 0:
                special_map_nodes[free_points.pop_front()] = node.duplicate()
                num_special_blocks -= 1
        default_block = map_area["default_block"]
        for x in range(map_size.x + 2):
            for y in range(current_floor, current_floor + num_floors):
                for z in range(map_size.y + 2):
                    if x == 0 or y == 0 or z == 0 or x == map_size.x + 1 or z == map_size.y + 1:
                        # Border of Bedrock or TopAir
                        block = BLOCK_BEDROCK if not default_block == BLOCK_TOP_AIR else BLOCK_TOP_AIR
                    else:
                        block = default_block
                    node = {
                        active = false,
                        block = block
                        }
                    map_nodes[Vector3(x, y, z)] = special_map_nodes.get(Vector3(x, y, z), node)
        current_floor += num_floors
    return map_nodes


func _put_scene_into_bbox(scene : Dictionary, bbox : AABB):
    var scene_map : Dictionary
    var scene_bbox : AABB
    var scene_rotation : Transform
    var rotation_range : int
    var bbox_translation : Vector3
    var bbox_position : Vector3
    var bbox_max_size : Vector3
    var bbox_size : Vector3
    var min_spawn_point : Vector3
    var max_spawn_point : Vector3
    var start_point : Vector3
    var new_vindex : Vector3
    var new_scene_map : Dictionary = {}
    var node : Dictionary
    var orientation_id : int
    var current_orientation_id : int
    var current_orientation_trans : Transform

    scene_map = self._load_scene(scene["path"])
    scene_bbox = self._get_bbox(scene_map)
    rotation_range = self._roll_range(scene.get("rotation_range", Vector2(0, 0))) % 4
    scene_rotation = Transform().rotated(Vector3(0, 1, 0), rotation_range * PI / 2).orthonormalized()
    if rotation_range == 0:
        bbox_translation = (bbox.position + bbox.size) * Vector3(0, 0, 0)
    elif rotation_range == 1:
        bbox_translation = (bbox.position + bbox.size) * Vector3(0, 0, 1)
    elif rotation_range == 2:
        bbox_translation = (bbox.position + bbox.size) * Vector3(1, 0, 1)
    elif rotation_range == 3:
        bbox_translation = (bbox.position + bbox.size) * Vector3(1, 0, 0)
    bbox_max_size = scene_rotation.xform(bbox).size.round() - scene_bbox.size
    if bbox_max_size.x <= 0 or bbox_max_size.y <= 0 or bbox_max_size.z <= 0:
        print("Cannot put scene into map, insufficient space.")
        return new_scene_map
    min_spawn_point = scene["spawn_pos_range_min"]
    min_spawn_point = Vector3( \
        fposmod(min_spawn_point.x, bbox_max_size.x), \
        fposmod(min_spawn_point.y, bbox_max_size.y), \
        fposmod(min_spawn_point.z, bbox_max_size.z) \
        )
    max_spawn_point = scene["spawn_pos_range_max"]
    max_spawn_point = Vector3( \
        fposmod(max_spawn_point.x, bbox_max_size.x), \
        fposmod(max_spawn_point.y, bbox_max_size.y), \
        fposmod(max_spawn_point.z, bbox_max_size.z) \
        )
    bbox_position = bbox.position - scene_bbox.position + min_spawn_point
    bbox_size = max_spawn_point - min_spawn_point
    print(min_spawn_point, max_spawn_point, bbox_position, bbox_size)
    bbox_size = Vector3(max(bbox_size.x, 0), max(bbox_size.y, 0), max(bbox_size.z, 0))
    start_point = self._get_random_point_in_box(AABB(bbox_position, bbox_size))
    print((scene_rotation.xform(start_point) + bbox_translation).round())
    for vindex in scene_map:
        new_vindex = (scene_rotation.xform(vindex + start_point) + bbox_translation).round()
        node = scene_map[vindex]
        current_orientation_id = node.get("orientation", 0)
        current_orientation_trans = Transform(self.ORIENTATION_ARRAY[current_orientation_id % 24])
        orientation_id = (scene_rotation * current_orientation_trans).basis.get_orthogonal_index()
        node["orientation"] = orientation_id
        if orientation_id == 0:
            # This is the default, no need to make the Dictionary bigger
            node.erase("orientation")
        new_scene_map[new_vindex] = node
        #print(vindex, ' -> ', new_vindex, ' (', scene_map[vindex], ')')
    return new_scene_map


func _roll_range(range_vector : Vector2):
    return self.rng.randi_range(range_vector.x, range_vector.y)


func generate_map_inflexible(map_generation_file_path : String) -> Dictionary:
    var config = self._load_config(map_generation_file_path)
    var map_size = self._get_map_size(config)
    var map_nodes = {}
    var block : String
    for y in range(map_size.y):
        for x in range(map_size.x):
            for z in range(map_size.z):
                if y == map_size.y - 1:
                    # Top of the world
                    block = BLOCK_TOP_AIR
                elif x == 0 or y == 0 or z == 0 or x == map_size.x - 1 or z == map_size.z - 1:
                    # Border
                    block = BLOCK_BEDROCK
                else:
                    block = DEFAULT_BLOCK
                map_nodes[Vector3(x, y, z)] = {
                    active = false,
                    block = block
                    }
    var scene_path = config.map_areas[0].map_scenes[0].path
    var scene_map = self._load_scene(scene_path)
    var scene_bbox = self._get_bbox(scene_map)
    var bbox : AABB = AABB(Vector3(0, 0, 0) - scene_bbox.position, Vector3(19, 1, 19) - scene_bbox.size)
    bbox.position += Vector3(1, 19, 1)
    var start_point = self._get_random_point_in_box(bbox)
    for vindex in scene_map:
        map_nodes[vindex + start_point] = scene_map[vindex]
    #print(start_point, bbox.position, bbox.end, bbox.size)
    return map_nodes


func _get_bbox(var map) -> AABB:
    var bbox : AABB = AABB(Vector3(0, 0, 0), Vector3(0, 0, 0))
    for vindex in map:
        bbox = bbox.expand(vindex)
    #print(bbox.position, bbox.end)
    return bbox


func _get_random_point_in_box(box : AABB) -> Vector3:
    var point = Vector3( \
        self.rng.randi_range(box.position.x, box.end.x), \
        self.rng.randi_range(box.position.y, box.end.y), \
        self.rng.randi_range(box.position.z, box.end.z))
    return point


func _get_all_points_in_bbox(box: AABB, var filter = null) -> Array:
    var points = []
    if not filter:
        filter = []
    for x in range(box.size.x):
        for y in range(box.size.y):
            for z in range(box.size.z):
                if not Vector3(x,y,z) + box.position in filter:
                    points.append(Vector3(x,y,z) + box.position)
    return points


func _get_map_size(var config) -> Vector3:
    var config_map_size = config["map_size"]
    var new_range
    var map_height = 0
    for area in config["map_areas"]:
        new_range = area["floor_range"]
        area["rolled_floor_range"] = self.rng.randi_range(new_range.x, new_range.y)
        map_height += area["rolled_floor_range"]
    var map_size = Vector3(config_map_size.x + 2, map_height + 2, config_map_size.y + 2)
    return map_size


func _load_scene(var path) -> Dictionary:
    var scene = resource_manager.get_resource(path).instance()
    var grid_map : GridMap
    var block_id : int
    var orientation_id : int
    var block : String
    var scene_map = {}
    if scene.is_class("GridMap"):
        grid_map = scene
    else:
        for node in scene.get_children():
            if node.is_class("GridMap"):
                grid_map = node
                break
    for vindex in grid_map.get_used_cells():
        block_id = grid_map.get_cell_item(vindex.x, vindex.y, vindex.z)
        orientation_id = grid_map.get_cell_item_orientation(vindex.x, vindex.y, vindex.z)
        block = grid_map.mesh_library.get_item_name(block_id)
        vindex *= Vector3(1, -1, 1)  # Since maps are drawn on the reverse y axis, scenes have to be reversed also
        scene_map[vindex] = {
            block = block,
            active = false
            }
        if orientation_id != 0:
            scene_map[vindex]["orientation"] = orientation_id
    scene.queue_free()
    return scene_map


func _load_config(var path) -> Dictionary:
    var loaded_config = self.load_json(path)
    var map_name = self.default_map_name
    var map_size = self.default_map_size
    var config = {
        name = map_name,
        map_size = map_size,
        map_areas = []
       }
    self._integrate_dictionary(loaded_config, config)
    return config


func _integrate_dictionary(source : Dictionary, target : Dictionary):
    var source_value
    var default_dict_name
    var new_item : Dictionary
    for key in target:
        if not source.has(key):
            continue
        source_value = source[key]
        if typeof(target[key]) == TYPE_VECTOR2:
            target[key] = Vector2(source_value[0], source_value[1])
        elif typeof(target[key]) == TYPE_VECTOR3:
            target[key] = Vector3(source_value[0], source_value[1], source_value[2])
        elif typeof(target[key]) == TYPE_ARRAY:
            default_dict_name = key.substr(0, key.length() - 1)
            for source_item in source_value:
                new_item = self.DEFAULT_CONTENTS.get(default_dict_name).duplicate(true)
                self._integrate_dictionary(source_item, new_item)
                target[key].append(new_item)
        else:
            target[key] = source_value


func load_json(var path) -> JSONParseResult:
    var file = File.new()
    file.open(path, file.READ)
    var content = parse_json(file.get_as_text())
    file.close()
    return content


func generate_test_map() -> Dictionary:
    var map_size = Vector3(20 + 2, 20 + 2, 20 + 2)
    var map_nodes = {}
    #var block_id : int
    var block : String
    for x in range(map_size.x):
        for y in range(map_size.y):
            for z in range(map_size.z):
                if y == map_size.y - 1:
                    # Top of the world
                    block = BLOCK_TOP_AIR
                elif x == 0 or y == 0 or z == 0 or x == map_size.x - 1 or z == map_size.z - 1:
                    # Border
                    block = BLOCK_BEDROCK
                else:
                    # Make a dirt qube with holes
                    if pow(x - map_size.x / 2, 2) + pow(z - map_size.z / 2, 2) <= 18:
                        block = "Air"
                    elif abs(x - z) < 2:
                        block = "Air"
                    elif pow(x - map_size.x / 2, 2) + pow(z - map_size.z / 2, 2) <= 32:
                        block = "CopperOre"
                    else:
                        block = DEFAULT_BLOCK
                #block_id = mesh_library.find_item_by_name(block)
                map_nodes[Vector3(x, y, z)] = {
                    active = false,
                    block = block
                    }
    return map_nodes

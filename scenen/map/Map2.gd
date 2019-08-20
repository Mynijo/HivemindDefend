extends Spatial

#const MapNode = preload("res://scenen/map/map_node.gd")

export (bool) var fog_of_war_flag = true

var map_nodes := {}
#var map_size : Vector3
var map_floors := {}
var map_blocks : Dictionary

const EAST = Vector3(1, 0, 0)
const WEST = Vector3(-1, 0, 0)
const NORTH = Vector3(0, 0, -1)
const SOUTH = Vector3(0, 0, 1)
const UP = Vector3(0, 1, 0)
const DOWN = Vector3(0, -1, 0)

const BLOCK_UNKNOWN = "Unknown"

#class MapNode:
#    var active = false
#    var block = "Unknown"
#    var rotatable = false


func gen_map_with_file(var map_generation_file_path = "res://scenen/map/map_generation_config2.json"):
    self.map_nodes = $MapGenerator.generate_map(map_generation_file_path)
    self._draw_grid_map()
    self._make_floors()
    activate_nodes(self.map_floors[0][0])  # The first block from the top floor


func _draw_grid_map(nodes_array = null):
    var unknown_id = self.get_block(BLOCK_UNKNOWN)["block_id"]
    var grid_id : int
    var rot_id : int
    var node : Dictionary
    if not nodes_array:
        # (Re)drawing the whole map
        $GridMap.clear()
        nodes_array = self.map_nodes
    for vindex in nodes_array:
        node = self.map_nodes[vindex]
        if node["active"]:
            grid_id = self.get_block(node["block"])["block_id"]
        else:
            grid_id = unknown_id
        rot_id = node.get("rotation", 0)
        $GridMap.set_cell_item(vindex.x, -vindex.y, vindex.z, grid_id, rot_id)  # The grid is drawn from top to bottom


func _make_floors():
    for vindex in self.map_nodes:
        var node_floor = int(vindex.y)
        if not self.map_floors.has(node_floor):
            self.map_floors[node_floor] = []
        self.map_floors[node_floor].append(vindex)


func show_floor(floor_id : int):
    var floor_cells = self.map_floors.get(floor_id)
    if floor_cells:
        self._draw_grid_map(floor_cells)
    else:
        print("Floor ", floor_id, " was empty!")


func hide_floor(floor_id : int):
    var floor_cells = self.map_floors.get(floor_id)
    if floor_cells:
        for vindex in floor_cells:
            $GridMap.set_cell_item(vindex.x, -vindex.y, vindex.z, -1)
    else:
        print("Floor ", floor_id, " was empty!")


func activate_nodes(pos : Vector3):
    var appended_nodes_num = 0
    var activated : bool = self._activate_node(pos)
    var queue := []
    if self._node_is_transparent(pos):
        queue.append(pos)
    while queue:
        pos = queue.pop_front()
        for direction in [EAST, WEST, NORTH, SOUTH, UP, DOWN]:
            activated = self._activate_node(pos + direction)
            if activated and self._node_is_transparent(pos + direction):
                queue.append(pos + direction)
                appended_nodes_num += 1
    print("Activated the chain ", appended_nodes_num, " times.")


func _activate_node(pos : Vector3) -> bool:
    var node = self.map_nodes.get(pos, null)
    if not node or node["active"]:
        return false
    var block = self.get_block(node["block"])
    var rot_id = node.get("rotation", 0)
    $GridMap.set_cell_item(pos.x, -pos.y, pos.z, block["block_id"], rot_id)
    node["active"] = true
    return true


func _node_is_transparent(pos : Vector3) -> bool:
    var node = self.map_nodes.get(pos, null)
    if not node:
        return false
    var block = self.get_block(node["block"])
    if not block:
        return false
    return block["transparent"] as bool


func get_block(block_name):
    if not block_name in self.map_blocks:
        var block_id = $GridMap.mesh_library.find_item_by_name(block_name)
        var block_mesh = $GridMap.mesh_library.get_item_mesh(block_id)
        var transparent = false
        var rotatable = false
        if block_mesh.is_class("CubeMesh"):
            transparent = block_mesh.material.flags_transparent
        elif block_name == "PlasticRamp":
            transparent = true
            rotatable = true
        self.map_blocks[block_name] = {
            "block_id": block_id,
            "transparent": transparent,
            "rotatable": rotatable
            }
    return self.map_blocks[block_name]


func get_map_node(position : Vector3) -> Dictionary:
    return self.map_nodes.get(position, null)


func save() -> Dictionary:
    var map_node_dict : Dictionary = {}
    var vstring: String
    for vindex in self.map_nodes:
        vstring = "{x}_{y}_{z}".format({x=vindex.x, y=vindex.y, z=vindex.z})
        map_node_dict[vstring] = self.map_nodes[vindex]
    var save_node_dict : Dictionary = {
        "map_nodes" : map_node_dict
    }
    var save_map_dict : Dictionary = {
        #"filename" : get_filename(),
        #"parent" : get_parent().get_path(),
        "path": self.get_path(),
        "data": save_node_dict
    }
    return save_map_dict


func load_game(data : Dictionary):
    var loaded_map_nodes = data["map_nodes"]
    self.map_nodes.clear()  # Deletes everything
    var vstring_array : Array
    var vindex : Vector3
    for vstring in loaded_map_nodes:
        vstring_array = vstring.split("_")
        vindex = Vector3(vstring_array[0], vstring_array[1], vstring_array[2])
        self.map_nodes[vindex] = loaded_map_nodes[vstring]
    self._draw_grid_map()

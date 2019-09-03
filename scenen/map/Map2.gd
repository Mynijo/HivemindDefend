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
const UP = Vector3(0, -1, 0)
const DOWN = Vector3(0, 1, 0)
const DIRECTION_MASK = {EAST: 0,
                        WEST: 1,
                        NORTH: 2,
                        SOUTH: 3,
                        UP: 4,
                        DOWN: 5}
const FULL_CONNECTIVITY = (1 << 6) - 1

const BLOCK_UNKNOWN = "Unknown"

#class MapNode:
#    var active = false
#    var block = "Unknown"
#    var rotatable = false


func gen_map_with_file(var map_generation_file_path = "res://scenen/map/map_generation_config2.json"):
    self.map_nodes = $MapGenerator.generate_map(map_generation_file_path)
    self._draw_grid_map()
    self._make_floors()
    emit_signal("map_generated", self)
    activate_nodes(self.map_floors[0][0])  # The first block from the top floor


func get_size() -> Vector3:
    if not self.map_nodes:
        return Vector3(0, 0, 0)
    return (self.map_nodes.keys().max() - self.map_nodes.keys().min() + Vector3(1, 1, 1))


func _draw_grid_map(nodes_array = null):
    var unknown_id = self.get_block(BLOCK_UNKNOWN)["block_id"]
    var grid_id : int
    var orientation_id : int
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
        orientation_id = node.get("orientation", 0)
        $GridMap.set_cell_item(vindex.x, -vindex.y, vindex.z, grid_id, orientation_id)  # The grid is drawn from top to bottom


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
    var connectivity := 0
    if self._node_is_transparent(pos):
        queue.append(pos)
    while queue:
        pos = queue.pop_front()
        for direction in [UP, DOWN, NORTH, SOUTH, EAST, WEST]:
            activated = self._activate_node(pos + direction)
            self._set_connectivity(pos, direction)
            if activated and self._node_is_transparent(pos + direction):
                queue.append(pos + direction)
                appended_nodes_num += 1

    print("Activated the chain ", appended_nodes_num, " times.")


func _set_connectivity(pos, direction):
    var self_node = self.map_nodes.get(pos, null)
    if not self_node:
        return
    var self_connectivity = self_node.get("connectivity", FULL_CONNECTIVITY)
    var self_block = self.get_block(self_node["block"])

    var other_node = self.map_nodes.get(pos + direction, null)
    var other_block = null
    var other_connectivity = null
    if other_node:
        other_block = self.get_block(other_node["block"])
        other_connectivity = other_node.get("connectivity", null)

#    if self_block["traversable"]:
#        print("_set_connectivity(", pos, ", ", direction, ")")

    if not self_block["traversable"]:
        self_connectivity = 0
    elif other_node == null:
        # Cannot connect to nonexistent block
        self_connectivity &= ~(1 << DIRECTION_MASK[direction])
    elif direction == UP and self_block["ramp"]:
        # Ramps only have two possble valid options
        self_connectivity &= (1 << DIRECTION_MASK[UP]) + (1 << DIRECTION_MASK[self.get_node_direction(pos)])
        if not other_block["traversable"] or other_block["ramp"]:
            self_connectivity &= ~(1 << DIRECTION_MASK[UP])
    elif direction == UP:
        # Without a ramp, you cannot go up
        self_connectivity &= ~(1 << DIRECTION_MASK[UP])
    elif direction == DOWN and other_block["ramp"]:
        # There is a ramp below, so only one side option is valid
        self_connectivity &= (1 << DIRECTION_MASK[DOWN]) + (1 << DIRECTION_MASK[-self.get_node_direction(pos + direction)])
    elif direction == DOWN and other_block["traversable"] and not self_block["ramp"]:
        # A block with air below is not connectable
        self_connectivity = 0
    elif not other_block["traversable"]:
        self_connectivity &= ~(1 << DIRECTION_MASK[direction])

    if !(other_connectivity == null):
        # The other block was nice enough to have their connectivity already calculated, so we are responsible for making the AStar connection
        if (self_connectivity & (1 << DIRECTION_MASK[direction])) and (other_connectivity & (1 << DIRECTION_MASK[-direction])):
            make_astar_connection(pos, pos + direction)
        else:
            # Me or the other block said, that a connection is not possible
            #if self_block["traversable"] and other_block["traversable"]:
                #print('Connection severed: ', pos, ' <-> ', pos + direction)
                #print(self_node["block"], ", ", self_connectivity, ", ", direction, ", ", DIRECTION_MASK[direction], ", ", (1 << DIRECTION_MASK[direction]), ", ", self_connectivity & (1 << DIRECTION_MASK[direction]))
                #print(other_node["block"], ", ", other_connectivity, ", ", -direction, ", ", DIRECTION_MASK[-direction], ", ", (1 << DIRECTION_MASK[-direction]), ", ", other_connectivity & (1 << DIRECTION_MASK[-direction]))
                #if self_block["ramp"]:
                #    print(self.get_node_direction(pos))
                #if other_block["ramp"]:
                #    print(self.get_node_direction(pos + direction))
            self_connectivity &= ~(1 << DIRECTION_MASK[direction])
            other_connectivity &= ~(1 << DIRECTION_MASK[-direction])
            other_node["connectivity"] = other_connectivity

    self_node["connectivity"] = self_connectivity
#    if self_block["traversable"] and other_block["traversable"]:
#        print(self.map_nodes[pos], ', ', other_node)
#        print("connectivity: ", self_connectivity, " - ", other_connectivity)
#        if other_connectivity != null:
#            print("connectivity: ", (self_connectivity & (1 << DIRECTION_MASK[direction])), " - ", (other_connectivity & (1 << DIRECTION_MASK[-direction])))


func make_astar_connection(a, b):
    print('Connection created: ', a, ' <-> ', b)
    pathfinding_manager.connect_nodes(a,b)


func _activate_node(pos : Vector3) -> bool:
    var node = self.map_nodes.get(pos, null)
    if not node or node["active"]:
        return false
    var block = self.get_block(node["block"])
    var orientation_id = node.get("orientation", 0)
    $GridMap.set_cell_item(pos.x, -pos.y, pos.z, block["block_id"], orientation_id)
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


func get_node_direction(pos : Vector3) -> Vector3:
    var node = self.map_nodes.get(pos, null)
    if not node:
        return Vector3(0, 0, 0)
    return $MapGenerator.ORIENTATION_ARRAY[node.get("orientation", 0) % 24].xform_inv(Vector3(1, 0, 0))


func get_block(block_name):
    if not block_name in self.map_blocks:
        var block_id = $GridMap.mesh_library.find_item_by_name(block_name)
        var block_mesh = $GridMap.mesh_library.get_item_mesh(block_id)
        var transparent = false
        var rotatable = false
        var traversable = false
        var ramp = false
        if block_mesh.is_class("CubeMesh"):
            transparent = block_mesh.material.flags_transparent
            if transparent and block_name != "TopAir":
                traversable = true
        elif block_name == "PlasticRamp":
            transparent = true
            rotatable = true
            traversable = true
            ramp = true
        self.map_blocks[block_name] = {
            "block_id": block_id,
            "transparent": transparent,
            "rotatable": rotatable,
            "traversable": traversable,
            "ramp": ramp
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

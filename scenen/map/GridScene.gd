extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    var used_cells = $GridMap.get_used_cells()
    self._copy_grid()
    print(used_cells.size())
    var mesh_library = $GridMap.mesh_library
    var block_ids = {}
    for item_id in mesh_library.get_item_list():
        print(mesh_library.get_item_mesh(item_id).material.flags_transparent)
        block_ids[mesh_library.get_item_name(item_id)] = item_id
    print(block_ids)


func _copy_grid():
    var used_cells = $GridMap.get_used_cells()
    print("Copy grid")
    for cell_vec in used_cells:
        $InformationGridMap.set_cell_item(cell_vec.x, cell_vec.y, cell_vec.z, \
            $GridMap.get_cell_item(cell_vec.x, cell_vec.y, cell_vec.z), \
            $GridMap.get_cell_item_orientation(cell_vec.x, cell_vec.y, cell_vec.z))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_BlockRemoveTimer_timeout():
    var used_cells = $GridMap.get_used_cells()
    if used_cells.size() <= 0:
        $BlockRemoveTimer.stop()
        return
    print("There are still ", used_cells.size(), " cells in the grid.")
    if used_cells.size() < 200:
        print("This is taking to long. Removing everything!")
        $GridMap.clear()
        return
    var cell_to_clear = used_cells[randi() % used_cells.size()]
    $GridMap.set_cell_item(cell_to_clear.x, cell_to_clear.y, cell_to_clear.z, -1)

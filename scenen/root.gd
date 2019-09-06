extends Node

const RAY_LENGTH = 1000


# Called when the node enters the scene tree for the first time.
func _ready():
#    var trans
#    var basis
#    var orientation_id
#    var rotation = Transform().rotated(Vector3(0, 1, 0), 2 * PI / 2).orthonormalized()
#    for current_orientation_id in range(24):
#        basis = $Map/MapGenerator.ORIENTATION_ARRAY[current_orientation_id % 24]
#        trans = Transform(basis)
#        orientation_id = (rotation * trans).basis.get_orthogonal_index()
#        print(current_orientation_id, " -> ", orientation_id)
    $BlockMarker.visible = false
    $AirMarker.visible = false
    var start_time = OS.get_ticks_msec()
    #$Map.gen_map_with_file("res://scenen/map/test_map_generation_config.json")
    $Map.gen_map_with_file()
    var map_gen_time = OS.get_ticks_msec() -start_time
    print("Gen Map:       ",map_gen_time / 1000.0, "Sec")

func _process(delta):
    self._update_marker()

func _on_SaveTimer_timeout():
    print("SaveTimer finished, saving game...")
    var start_time = OS.get_ticks_msec()
    save_load_manager.save_game()
    var map_save_time = OS.get_ticks_msec() - start_time
    print("save_game:     ",map_save_time / 1000.0, "Sec")
    $LoadTimer.start()


func _on_LoadTimer_timeout():
    print("LoadTimer finished, loading game...")
    var start_time = OS.get_ticks_msec()
    save_load_manager.load_game()
    var map_load_time = OS.get_ticks_msec() - start_time
    print("load_game:    ",map_load_time / 1000.0, "Sec")
    get_tree().get_root().print_stray_nodes()


var current_floor = 0
var floor_mod = 1
func _on_HideTimer_timeout():
    if current_floor >= 10 :
        floor_mod = -1
    elif current_floor < 0:
        $HideTimer.stop()
        return
    if floor_mod > 0:
        #print("Hiding floor ", current_floor)
        $Map.hide_floor(current_floor)
    else:
        #print("Showing floor ", current_floor)
        $Map.show_floor(current_floor)
    current_floor += floor_mod

func _input(event):
    var block_position
    var air_position
    if event is InputEventMouse:
        if event is InputEventMouseButton and event.is_pressed() and $AirMarker.visible:
            air_position = $AirMarker.translation * Vector3(1, -1, 1)
            if $DebugInfo.path_to != Vector3(-1, -1, -1):
                $DebugInfo.path_to = Vector3(-1, -1, -1)
                $DebugInfo.path_from = air_position
                $DebugInfo/Labels/PathNodes.text = "PathNodes: " + str($DebugInfo.path_from) + " -> NULL"
            else:
                $DebugInfo.path_to = air_position
                $DebugInfo/Labels/PathNodes.text = "PathNodes: " + str($DebugInfo.path_from) + " -> " + str($DebugInfo.path_to)
    elif event is InputEventKey and event.pressed and event.scancode == KEY_B and $BlockMarker.visible:
        block_position = $BlockMarker.translation * Vector3(1, -1, 1)
        $Map.break_block(block_position)
    elif event is InputEventKey and event.pressed and event.scancode == KEY_P and $AirMarker.visible:
        air_position = $AirMarker.translation * Vector3(1, -1, 1)
        $Map.place_block(air_position, "Dirt")


func _update_marker():
    var marker_position
    var block_position
    var air_position
    var mouse_position = get_viewport().get_mouse_position()
    var from_pos = $CamBase/Camera.project_ray_origin(mouse_position)
    var to_pos = from_pos + $CamBase/Camera.project_ray_normal(mouse_position) * RAY_LENGTH
    var hit = $Map.get_world().get_direct_space_state().intersect_ray(from_pos, to_pos)
    if hit:
        if hit.get("collider") == $Map/GridMap:
            #text = hit.collider.world_to_map(hit.position) * Vector3(1, -1, 1)
            marker_position = (hit.position - 0.1 * hit.normal).round()
            block_position = marker_position * Vector3(1, -1, 1)
            $BlockMarker.translation = marker_position
            $BlockMarker.visible = true
            marker_position = (hit.position + 0.5 * hit.normal).round()
            air_position = marker_position * Vector3(1, -1, 1)
            if $Map.get_map_node(air_position) and $Map.get_map_node(air_position).get("block") == $Map.BLOCK_AIR:
                $AirMarker.translation = marker_position
                $AirMarker.visible = true
            else:
                $AirMarker.visible = false
        else:
            $BlockMarker.visible = false
            $AirMarker.visible = false
    else:
        $BlockMarker.visible = false
        $AirMarker.visible = false
    $DebugInfo/Labels/CoordinateValue.text = str(mouse_position) + ' -> ' + str(hit.get("position")) + " [" + str(block_position) + "]"
    $DebugInfo/Labels/BlockTypeValue.text = str($Map.map_nodes.get(block_position)) + "\n" + str($Map.map_nodes.get(air_position))
    #$DebugInfo/Labels/BlockTypeValue.text = str(hit)

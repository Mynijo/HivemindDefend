extends Node

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
    var start_time = OS.get_ticks_msec()
    #$Map.gen_map_with_file("res://scenen/map/test_map_generation_config.json")
    $Map.gen_map_with_file()
    var map_gen_time = OS.get_ticks_msec() -start_time
    print("Gen Map:       ",map_gen_time / 1000.0, "Sec")

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

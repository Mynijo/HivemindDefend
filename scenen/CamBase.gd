extends Spatial

const MOVE_MARGIN = 20
const MOVE_SPEED = 30

const ray_length = 1000
onready var cam = $Camera

var move_cam_vec = Vector3()
var actual_zoom = 0
var zoom_max_out = 100
var zoom_max_in = -100

func _init():
    pass
    #Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(delta):
    var m_pos = get_viewport().get_mouse_position()
    calc_move(m_pos, delta)


func calc_move(m_pos, delta):
    var v_size = get_viewport().size
    var cam_rotation = 0

    if Input.is_action_pressed("camera_left"):
        move_cam_vec -= transform.basis.x
    if Input.is_action_pressed("camera_up"):
        move_cam_vec -= transform.basis.z
    if Input.is_action_pressed("camera_right"):
        move_cam_vec += transform.basis.x
    if Input.is_action_pressed("camera_down"):
        move_cam_vec += transform.basis.z
    if Input.is_action_pressed("camera_rotate_left"):
        cam_rotation -= 1
    if Input.is_action_pressed("camera_rotate_rigth"):
        cam_rotation += 1

    rotate(Vector3(0,1,0),cam_rotation* delta)
    global_translate(move_cam_vec * delta * MOVE_SPEED)
    move_cam_vec = Vector3()


func _zoom_camera(zoom):
    if actual_zoom + zoom >= zoom_max_in and actual_zoom + zoom <= zoom_max_out :
        move_cam_vec.y += zoom
        actual_zoom += zoom

func _input(event):
    if event.is_action_pressed("camera_zoom_in"):
        _zoom_camera(-1)
    elif event.is_action_pressed("camera_zoom_out"):
        _zoom_camera(1)
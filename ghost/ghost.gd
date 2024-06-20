class_name Ghost
extends Node2D

enum eye_orientation {UP, DOWN, LEFT, RIGHT}

@export var tile_map : TileMap
@export var scatter_corner : Vector2i
@export var target_position : Vector2i
@export var chase_target_position : Vector2i
@export var return_position : Vector2i

const SCATTER_LOOP_PATH_UPPER_LEFT : Array[Vector2i] = [
	Vector2i(4, 3),
	Vector2i(5, 3),
	Vector2i(6, 3),
	Vector2i(7, 3),
	Vector2i(8, 3),
	Vector2i(8, 4),
	Vector2i(8, 5),
	Vector2i(8, 6),
	Vector2i(8, 7),
	Vector2i(7, 7),
	Vector2i(6, 7),
	Vector2i(5, 7),
	Vector2i(4, 7),
	Vector2i(3, 7),
	Vector2i(3, 6),
	Vector2i(3, 5),
	Vector2i(3, 4),
	Vector2i(3, 3)
]

const SCATTER_LOOP_PATH_UPPER_RIGHT : Array[Vector2i] = [
	Vector2i(27, 3),
	Vector2i(26, 3),
	Vector2i(25, 3),
	Vector2i(24, 3),
	Vector2i(23, 3),
	Vector2i(23, 4),
	Vector2i(23, 5),
	Vector2i(23, 6),
	Vector2i(23, 7),
	Vector2i(24, 7),
	Vector2i(25, 7),
	Vector2i(26, 7),
	Vector2i(27, 7),
	Vector2i(28, 7),
	Vector2i(28, 6),
	Vector2i(28, 5),
	Vector2i(28, 4),
	Vector2i(28, 3)
]

const SCATTER_LOOP_PATH_LOWER_LEFT : Array[Vector2i] = [
	Vector2i(3, 30),
	Vector2i(3, 29),
	Vector2i(3, 28),
	Vector2i(4, 28),
	Vector2i(5, 28),
	Vector2i(6, 28),
	Vector2i(7, 28),
	Vector2i(8, 28),
	Vector2i(8, 27),
	Vector2i(8, 26),
	Vector2i(8, 25),
	Vector2i(9, 25),
	Vector2i(10, 25),
	Vector2i(11, 25),
	Vector2i(11, 26),
	Vector2i(11, 27),
	Vector2i(11, 28),
	Vector2i(12, 28),
	Vector2i(13, 28),
	Vector2i(14, 28),
	Vector2i(14, 29),
	Vector2i(14, 30),
	Vector2i(14, 31),
	Vector2i(13, 31),
	Vector2i(12, 31),
	Vector2i(11, 31),
	Vector2i(10, 31),
	Vector2i(9, 31),
	Vector2i(8, 31),
	Vector2i(7, 31),
	Vector2i(6, 31),
	Vector2i(5, 31),
	Vector2i(4, 31),
	Vector2i(3, 31)
]

const SCATTER_LOOP_PATH_LOWER_RIGHT : Array[Vector2i] = [
	Vector2i(27, 31),
	Vector2i(26, 31),
	Vector2i(25, 31),
	Vector2i(24, 31),
	Vector2i(23, 31),
	Vector2i(22, 31),
	Vector2i(21, 31),
	Vector2i(20, 31),
	Vector2i(19, 31),
	Vector2i(18, 31),
	Vector2i(17, 31),
	Vector2i(17, 30),
	Vector2i(17, 29),
	Vector2i(17, 28),
	Vector2i(18, 28),
	Vector2i(19, 28),
	Vector2i(20, 28),
	Vector2i(20, 27),
	Vector2i(20, 26),
	Vector2i(20, 25),
	Vector2i(21, 25),
	Vector2i(22, 25),
	Vector2i(23, 25),
	Vector2i(23, 26),
	Vector2i(23, 27),
	Vector2i(23, 28),
	Vector2i(24, 28),
	Vector2i(25, 28),
	Vector2i(26, 28),
	Vector2i(27, 28),
	Vector2i(28, 28),
	Vector2i(28, 29),
	Vector2i(28, 30),
	Vector2i(28, 31)
]

const SCATTER_LOOP = {
	Vector2i(3, 3) : SCATTER_LOOP_PATH_UPPER_LEFT,
	Vector2i(28, 3) : SCATTER_LOOP_PATH_UPPER_RIGHT,
	Vector2i(3, 31) : SCATTER_LOOP_PATH_LOWER_LEFT,
	Vector2i(28, 31) : SCATTER_LOOP_PATH_LOWER_RIGHT
}

const SPEED = 60
const SPRITE_RADIUS = 8.

var astargrid : AStarGrid2D
var current_map_position : Vector2i
var is_moving = false
var current_target : Vector2i
var current_path : Array[Vector2i]
var path_step_index : int
var states : Dictionary
var initial_state : GhostState
var current_state : GhostState

func _ready():
	initial_state = $ChaseState
	current_map_position = tile_map.local_to_map(position)
	setup_grid()
	setup_states()

func setup_states():
	for child in get_children():
		if child is GhostState:
			states[child.name] = child
			child.connect("changed_state", on_state_change)
	current_state = initial_state
	current_state.enter()

func on_state_change(state, new_state_name):
	print("Entering new state:" + new_state_name)
	if state != current_state:
		return
	var new_state = states.get(new_state_name)
	if !new_state:
		return
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state

func setup_grid():
	astargrid = AStarGrid2D.new()
	astargrid.size = Vector2i(30, 33)
	astargrid.update()
	astargrid.diagonal_mode = astargrid.DIAGONAL_MODE_NEVER
	astargrid.update()
	for cell in tile_map.get_used_cells(0):
		var cell_position = Vector2i(cell.x, cell.y)
		var cell_map_data = tile_map.get_cell_tile_data(0, cell_position)
		if cell_map_data:
			astargrid.set_point_solid(cell_position, !cell_map_data.get_custom_data("walkable"))

func _physics_process(delta):
	current_state.update(delta)

func find_path():
	if astargrid.is_in_bounds(target_position.x, target_position.y) && \
	!astargrid.is_point_solid(target_position):
		current_path = astargrid.get_id_path(current_map_position, target_position)
		if current_path.size() > 1:
			path_step_index = 1
			current_target = current_path[path_step_index]
	else:
		follow_path()

func follow_path():
	path_step_index += 1
	if current_path.size() > path_step_index:
		current_target = current_path[path_step_index]

func move(delta : float):
	is_moving = true
	var direction = current_target - tile_map.local_to_map(position)
	var local_target = tile_map.map_to_local(current_target)
	change_eye_sprite(direction)
	position.x = move_toward(position.x, local_target.x + direction.x * SPRITE_RADIUS, delta * SPEED)
	position.y = move_toward(position.y, local_target.y + direction.y * SPRITE_RADIUS, delta * SPEED)
	if tile_map.local_to_map(position - direction * SPRITE_RADIUS) == current_target:
		current_map_position = current_target
		is_moving = false

func change_eye_sprite(direction : Vector2i):
	if direction == Vector2i.UP && $Sprite2D.frame != eye_orientation.UP:
		$Sprite2D.frame = eye_orientation.UP
	if direction == Vector2i.DOWN && $Sprite2D.frame != eye_orientation.DOWN:
		$Sprite2D.frame = eye_orientation.DOWN
	if direction == Vector2i.LEFT && $Sprite2D.frame != eye_orientation.LEFT:
		$Sprite2D.frame = eye_orientation.LEFT
	if direction == Vector2i.RIGHT && $Sprite2D.frame != eye_orientation.RIGHT:
		$Sprite2D.frame = eye_orientation.RIGHT

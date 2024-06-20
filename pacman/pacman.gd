extends Node2D

@export var tile_map : TileMap

const SPEED = 60.
const SPRITE_RADIUS = 8.

var direction = Vector2i.ZERO
var current_position : Vector2i
var is_moving = false

signal changed_tile

func _ready():
	current_position = tile_map.local_to_map(position)

func _physics_process(delta):
	if Input.is_action_pressed("ui_up") && (
	(!is_moving && is_target_position_walkable(current_position + Vector2i.UP)) || \
	(is_moving && direction == Vector2i.DOWN)):
		direction = Vector2i.UP
		$AnimatedSprite2D.rotation_degrees = -90
		$AnimatedSprite2D.play("moving")
	if Input.is_action_pressed("ui_down") && (
	(!is_moving && is_target_position_walkable(current_position + Vector2i.DOWN)) || \
	(is_moving && direction == Vector2i.UP)):
		direction = Vector2i.DOWN
		$AnimatedSprite2D.rotation_degrees = 90
		$AnimatedSprite2D.play("moving")
	if Input.is_action_pressed("ui_right") && (
	(!is_moving && is_target_position_walkable(current_position + Vector2i.RIGHT)) || \
	(is_moving && direction == Vector2i.LEFT)):
		direction = Vector2i.RIGHT
		$AnimatedSprite2D.rotation_degrees = 0
		$AnimatedSprite2D.play("moving")
	if Input.is_action_pressed("ui_left") && (
	(!is_moving && is_target_position_walkable(current_position + Vector2i.LEFT)) || \
	(is_moving && direction == Vector2i.RIGHT)):
		direction = Vector2i.LEFT
		$AnimatedSprite2D.rotation_degrees = 180
		$AnimatedSprite2D.play("moving")
	if direction != Vector2i.ZERO:
		move(delta)

func move(delta):
	var target_position = current_position + direction
	is_moving = true
	if tile_map.local_to_map(position - direction * SPRITE_RADIUS) == target_position:
		is_moving = false
		current_position = target_position
		target_position = current_position + direction
		changed_tile.emit(current_position, direction)
	var local_target_position = tile_map.map_to_local(target_position)
	if is_target_position_walkable(target_position):
		var local_target = local_target_position + direction * SPRITE_RADIUS
		position.x = move_toward(position.x, local_target.x, delta * SPEED)
		position.y = move_toward(position.y, local_target.y, delta * SPEED)
	else:
		is_moving = false
		direction = Vector2i.ZERO
		$AnimatedSprite2D.stop()

func is_target_position_walkable(target_position):
	var tile_data = tile_map.get_cell_tile_data(0, target_position)
	return tile_data && tile_data.get_custom_data("walkable")

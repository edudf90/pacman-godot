extends Node2D

@export var tilemap : TileMap

const SPEED = 60.
const SPRITE_RADIUS = 8.

var direction = Vector2i(0, 0)
var current_position : Vector2i

func _ready():
	current_position = tilemap.local_to_map(position)

func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		direction = Vector2i.UP
		$AnimatedSprite2D.rotation_degrees = -90
		$AnimatedSprite2D.play("moving")
	if Input.is_action_pressed("ui_down"):
		direction = Vector2i.DOWN
		$AnimatedSprite2D.rotation_degrees = 90
		$AnimatedSprite2D.play("moving")
	if Input.is_action_just_pressed("ui_right"):
		direction = Vector2i.RIGHT
		$AnimatedSprite2D.rotation_degrees = 0
		$AnimatedSprite2D.play("moving")
	if Input.is_action_just_pressed("ui_left"):
		direction = Vector2i.LEFT
		$AnimatedSprite2D.rotation_degrees = 180
		$AnimatedSprite2D.play("moving")
	move(delta)

func move(delta):
	var target_position = current_position + direction
	if tilemap.local_to_map(position - direction * SPRITE_RADIUS) == target_position:
		current_position = target_position
		target_position = current_position + direction
	var local_target_position = tilemap.map_to_local(target_position)
	var tile_data = tilemap.get_cell_tile_data(0, target_position)
	if tile_data && tile_data.get_custom_data("walkable"):
		var local_target = local_target_position + direction * SPRITE_RADIUS
		position.x = move_toward(position.x, local_target.x, delta * SPEED)
		position.y = move_toward(position.y, local_target.y, delta * SPEED)
	else:
		$AnimatedSprite2D.stop()

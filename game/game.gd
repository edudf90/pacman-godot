extends Node2D


func _ready():
	$Blinky/AnimatedSprite2D.modulate = Color.CRIMSON
	$Pinky/AnimatedSprite2D.modulate = Color.VIOLET
	$Inky/AnimatedSprite2D.modulate = Color.TURQUOISE
	$Clyde/AnimatedSprite2D.modulate = Color.SANDY_BROWN
	$Blinky/Sprite2D.frame = 1
	$Pinky/Sprite2D.frame = 2
	$Inky/Sprite2D.frame = 3
	$Pacman.changed_tile.connect(update_ghost_targets)


func _process(delta):
	pass

func update_ghost_targets(target_position : Vector2i, direction : Vector2i):
	update_blinky_target(target_position)
	update_pinky_target(target_position, direction)
	update_inky_target(target_position, direction)
	update_clyde_target()

func update_blinky_target(target_position : Vector2i):
	$Blinky.chase_target_position = target_position

func update_pinky_target(target_position : Vector2i, direction : Vector2i):
	$Pinky.chase_target_position = target_position + 4 * direction

func update_inky_target(target_position : Vector2i, direction : Vector2i):
	var blinky_position = $TileMap.local_to_map($Blinky.position)
	var two_in_front_pacman = target_position + 2 * direction
	$Inky.chase_target_position = two_in_front_pacman + abs(two_in_front_pacman - blinky_position)

func update_clyde_target():
	var target_position = $TileMap.local_to_map($Pacman.position)
	$Clyde.chase_target_position = target_position
	var clyde_pacman_distance = $TileMap.local_to_map($Clyde.position) - target_position
	if abs(clyde_pacman_distance.x) + abs(clyde_pacman_distance.y) < 8:
		$Clyde.chase_target_position = $Clyde.scatter_corner

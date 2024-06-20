extends GhostState

var ghost : Ghost

func _ready():
	ghost = get_parent()
	
func enter():
	ghost.target_position = ghost.return_position
	ghost.find_child("AnimatedSprite2D").visible = false
	ghost.find_path()

func exit():
	ghost.find_child("AnimatedSprite2D").visible = true

func update(delta : float):
	if !ghost.is_moving && ghost.current_map_position == ghost.target_position:
		changed_state.emit(self, "ChaseState")
	if !ghost.is_moving:
		ghost.find_path()
	ghost.move(delta)


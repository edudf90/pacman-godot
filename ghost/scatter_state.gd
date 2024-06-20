extends GhostState

var ghost : Ghost
var timer : Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", on_timer_timeout)
	ghost = get_parent()

func enter():
	ghost.target_position = ghost.scatter_corner
	ghost.find_path()
	timer.start(5.)

func exit():
	timer.stop()

func update(delta : float):
	ghost.move(delta)
	if !ghost.is_moving:
		if ghost.current_map_position == ghost.scatter_corner:
			ghost.current_path = ghost.SCATTER_LOOP[ghost.scatter_corner]
			ghost.path_step_index = 0
		ghost.follow_path()

func on_timer_timeout():
	timer.stop()
	changed_state.emit(self, "ChaseState")

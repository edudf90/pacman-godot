extends GhostState

var ghost : Ghost
var timer : Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", on_timer_timeout)
	ghost = get_parent()

func enter():
	timer.start(10.)

func exit():
	timer.stop()

func update(delta : float):
	ghost.target_position = ghost.chase_target_position
	if !ghost.is_moving:
		ghost.find_path()
	ghost.move(delta)

func on_timer_timeout():
	timer.stop()
	changed_state.emit(self, "ScatterState")

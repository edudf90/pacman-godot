extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Blinky/AnimatedSprite2D.modulate = Color.CRIMSON
	$Pinky/AnimatedSprite2D.modulate = Color.VIOLET
	$Inky/AnimatedSprite2D.modulate = Color.TURQUOISE
	$Clyde/AnimatedSprite2D.modulate = Color.SANDY_BROWN
	$Blinky/Sprite2D.frame = 1
	$Pinky/Sprite2D.frame = 2
	$Inky/Sprite2D.frame = 3
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

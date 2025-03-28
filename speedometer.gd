extends TextureProgressBar

@onready var player : CharacterBody3D = get_node("../../Player")

func _ready() -> void:
	max_value = 10

func _physics_process(delta: float) -> void:
	#print(player.velocity.length())
	var vel = player.velocity.length()
	value = vel
	$SpeedLabel.text = str(vel)

extends Node2D

@onready var player: = $ActorsContainer/Player
@onready var camera: = $Camera

# 摄像机逻辑，当角色X位置大于摄像机X，摄像机跟随角色
func _process(_delta: float) -> void:
	if player.position.x > camera.position.x:
		camera.position.x = player.position.x

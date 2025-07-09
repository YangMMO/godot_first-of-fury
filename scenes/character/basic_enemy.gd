class_name BasicEnemy
extends Character

@export var player : Player

# 按键事件, 通过扩展脚本继承类(Character)并重写事件
func handle_input() -> void:
	if player != null:
		var direction := (player.position - position).normalized()
		velocity = direction * speed

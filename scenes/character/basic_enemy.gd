class_name BasicEnemy
extends Character

@export var player : Player

# 按键事件, 通过扩展脚本继承类(Character)并重写事件
func handle_input() -> void:
	# 加入can_move()判断是因为确保敌人处于行走或默认状态，当敌人转为hurt受伤状态去爱时，取消跟踪player位置
	if player != null and can_move():
		var direction := (player.position - position).normalized()
		velocity = direction * speed

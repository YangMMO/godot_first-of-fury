class_name Player
extends Character

# 按键事件
func handle_input() -> void:
		# 向量归1化移动
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed('attack'):
		state = State.ATTACK
	if can_jump() and Input.is_action_just_pressed('jump'):
		state = State.TAKEOFF
	if can_jumpkick() and Input.is_action_just_pressed('attack'):
		state = State.JUMPKICK

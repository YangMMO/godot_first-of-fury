class_name Player
extends Character

# 获取槽位节点数组
@onready var enemy_slots : Array = $EnemySlots.get_children()

# 按键事件
func handle_input() -> void:
		# 向量归1化移动
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed('attack'):
		state = State.ATTACK
		
		# 判断攻击否成功, 成功则修改攻击索引动画，同时重置攻击是否成功变量未否
		if is_last_hit_successful:
			attack_combo_index = (attack_combo_index + 1) % anim_attcks.size()
			is_last_hit_successful = false
		else:
			attack_combo_index = 0 #重置攻击动画
		
	if can_jump() and Input.is_action_just_pressed('jump'):
		state = State.TAKEOFF
	if can_jumpkick() and Input.is_action_just_pressed('attack'):
		state = State.JUMPKICK

# 接收敌人，并返回槽位
func reserve_slot(enemy: BasicEnemy) -> EnemySlot:
	# 检查槽位数组，槽位是否空闲，并返回新的槽位数组	
	var available_slots := enemy_slots.filter(
		func(slot): return slot.is_free()
	)
	
	# 槽位是否为0,0则返回
	if available_slots.size() == 0:
		return null
	
	# 自定义排序，检测槽位与敌人距离
	available_slots.sort_custom(
		func(a: EnemySlot, b: EnemySlot):
			# 槽位player的子节点，如果局部坐标，只是获取槽位的相对位置
			var dist_a := (enemy.global_position - a.global_position).length()
			var dist_b := (enemy.global_position - b.global_position).length()
			return dist_a < dist_b # 按最短距离排序槽位
	)
	
	# 占用槽位， 返回最近槽位
	available_slots[0].occupy(enemy)
	return available_slots[0]

# 释放槽位
func free_slot(enemy: BasicEnemy) -> void:
	# 如果槽位数组内包含该敌人，则返回该槽位
	var target_slots := enemy_slots.filter(
		func(slot: EnemySlot): return slot.occupant == enemy
	)
	# 同时判断槽位长度，将其释放
	if  target_slots.size() == 1:
		target_slots[0].free_up()

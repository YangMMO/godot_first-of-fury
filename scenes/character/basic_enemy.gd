class_name BasicEnemy
extends Character

@export var player : Player

var player_slot : EnemySlot = null

# 按键事件, 通过扩展脚本继承类(Character)并重写事件
func handle_input() -> void:
	# 加入can_move()判断是因为确保敌人处于行走或默认状态，当敌人转为hurt受伤状态去爱时，取消跟踪player位置
	if player != null and can_move():
		
		# 判断槽位是否为空，空则赋予槽位
		if  player_slot == null:
			player_slot = player.reserve_slot(self)
		
		# 判断槽位是否为空，不为空则移动
		if  player_slot != null:
			var direction := (player_slot.global_position - global_position).normalized()
			if (player_slot.global_position - global_position).length() < 1:
				velocity = Vector2.ZERO
			else:
				velocity = direction * speed

# 重写敌人受伤逻辑
func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	super.on_receive_damage(amount, direction, hit_type) # 使用父类方法
	
	# 添加额外逻辑
	if current_health == 0:
		player.free_slot(self) # 从player的槽位中移除自身（敌人）

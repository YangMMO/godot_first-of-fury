class_name Character
extends CharacterBody2D

const GRAVITY := 600.0

@export var can_respawn: bool # 角色是否可以重生
@export var damage: int # 伤害值
@export var damage_power: int # 强力攻击伤害值
@export var duration_grounded: float # 倒地持续时间
@export var flight_speed: float # 击飞速度
@export var jump_intensity: int # 跳跃强度
@export var knockback_intensity : float # 被击退强度
@export var knockdown_intensity : float # 被击倒强度
@export var max_health: int # 最大生命值
@export var speed: float # 速度

# 加载完成后取得节点
@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var collateral_damage_emitter : Area2D = $CollateralDamageEmitter
@onready var collision_shape := $CollisionShape2D 
@onready var damage_emitter := $DamageEmitter # Area2D，检测区域
@onready var damage_receiver := $DamageReceiver

# 定义的状态
enum State {IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT, FALL, GROUNDED, DEATH, FLY}

# 攻击状态
var anim_attcks := ['punch', 'punch_alt', 'kick', 'roundkick']

# 定义状态所对应动画名称
var anim_map : Dictionary = {
	State.IDLE: 'idle',
	State.WALK: 'walk',
	State.TAKEOFF: 'takeoff',
	State.JUMP: 'jump',
	State.LAND: 'land',
	State.JUMPKICK: 'jumpkick',
	State.HURT: 'hurt',
	State.FALL: 'fall',
	State.GROUNDED: 'grounded',
	State.DEATH: 'grounded',
	State.FLY: 'fly',
}

var attack_combo_index := 0 # 连招索引
var current_health := 0 # 当前生命值
var heading := Vector2.RIGHT # 面朝方向
var height := 0.0 # 高度
var height_speed := 0.0 # 高度速度
var is_last_hit_successful := false # 最后一击是否成功
var state = State.IDLE # 默认状态
var time_since_grounded := Time.get_ticks_msec() # 落地时间

# 准备阶段
func _ready() -> void:
	# 当检测域有碰撞物体进入时，(area_entered)信号通过链接调用一个方法（on_emit_damage）
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	# 强力攻击，击飞连续碰撞
	collateral_damage_emitter.area_entered.connect(on_emit_collateral_damage.bind())
	collateral_damage_emitter.body_entered.connect(on_wall_hit.bind())
	current_health = max_health # 初始化生命值

# 进程处理阶段
func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	handle_air_time(delta)
	handle_grounded()
	handle_death(delta)
	setHeading()
	fiip_sprites()
	character_sprite.position = Vector2.UP * height
	collision_shape.disabled = is_collision_disabled()
	move_and_slide()

# 移动事件
func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK

# 按键事件, 通过扩展脚本继承类(Character)并重写事件
func handle_input() -> void:
	pass

# 落地事件
func handle_grounded() -> void:
	# 是否落地状态，且落地时间大于持续落地时间
	if state == State.GROUNDED and (Time.get_ticks_msec() - time_since_grounded > duration_grounded):
		if current_health == 0:
			state = State.DEATH  # 切到死亡状态
		else:
			state = State.LAND # 切换回着陆状态

# 死亡事件
func handle_death(delta) -> void:
	# 处于死亡状态，且角色不可重生
	if state == State.DEATH and not can_respawn:
		modulate.a -= delta / 2.0
		if modulate.a <= 0:
			queue_free()

# 动画事件，根据状态动画播放
func handle_animations() -> void:
	# 是否为攻击状态，否则播放其他动画
	if state == State.ATTACK:
		animation_player.play(anim_attcks[attack_combo_index])
	elif animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])

# 空中时间，计算击退方式
func handle_air_time(delta: float) -> void:
	if [State.JUMP, State.JUMPKICK, State.FALL].has(state):
		height += height_speed * delta
		if height < 0:
			height = 0
			if state == State.FALL:
				state = State.GROUNDED
				time_since_grounded = Time.get_ticks_msec()
			else:
				state = State.LAND
			velocity = Vector2.ZERO
		else:
			height_speed -= GRAVITY * delta

# 设置朝向 基类，根据角色重写方法
func setHeading() -> void:
	pass

# 翻转角色左右
func fiip_sprites() -> void:
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
		damage_emitter.scale.x = 1
	else:
		character_sprite.flip_h = true
		damage_emitter.scale.x = -1

# 监听状态否可移动
func can_move() -> bool:
	return state == State.IDLE or state == State.WALK

# 监听状态否可攻击
func can_attack() -> bool:
	return state == State.IDLE or state == State.WALK

# 监听状态否可跳跃
func can_jump() -> bool:
	return state == State.IDLE or state == State.WALK

# 监听状态否可跳跃飞踢
func can_jumpkick() -> bool:
	return state == State.JUMP

# 监听状态否可跳跃飞踢
func can_get_hurt() -> bool:
	return [State.IDLE, State.WALK, State.TAKEOFF, State.JUMP, State.LAND, State.HURT].has(state)

func is_collision_disabled() -> bool:
	return [State.GROUNDED, State.DEATH, State.FLY].has(state)

# 行动结束，状态重置
func on_aciton_complete() -> void:
	state = State.IDLE

# 完成起跳动作
func on_takeoff_complete() -> void:
	state = State.JUMP
	height_speed = jump_intensity

# 完成落地动作
func on_land_complete() -> void:
	state = State.IDLE

# 接收到伤害 amount：收到的害值
func on_receive_damage(amount: int, direction: Vector2, hit_type:DamageReceiver.HitType) -> void:
	# 什么状态下可以接收到伤害
	if can_get_hurt():
		print(amount)
		# 当前生命值计算， clamp限制生命值范围
		current_health = clamp(current_health - amount, 0, max_health)
		# 击倒判断 elif 判断否受到强力攻击, 都是算为普通伤害
		if current_health == 0 or hit_type == DamageReceiver.HitType.KNOCKDOWN:
			state = State.FALL
			height_speed = knockdown_intensity # 击到弹起高度
			velocity = direction * knockback_intensity
		elif hit_type == DamageReceiver.HitType.POWER:
			state = State.FLY
			velocity = direction * flight_speed
		else:
			state = State.HURT
			velocity = direction * knockback_intensity

# 发射器 发送伤害，receiver为DamageReceiver类，此类下有一个信号(damage_received)，并过此信号发送伤害值息
func on_emit_damage(receiver: DamageReceiver) -> void:
	# 攻击类型记录
	var hit_type := DamageReceiver.HitType.NORMAL
	# 三目运算，如果接收器器的位置<全局位置，则代表接收器的位置在左侧
	var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	# 攻击伤害
	var current_damage = damage
	# 跳踢判断
	if state == State.JUMPKICK:
		hit_type = DamageReceiver.HitType.KNOCKDOWN
	# combo攻击断，最后一帧时，变为强力攻击
	if attack_combo_index == anim_attcks.size() - 1:
		hit_type = DamageReceiver.HitType.POWER
		current_damage = damage_power
	receiver.damage_received.emit(current_damage, direction, hit_type)
	is_last_hit_successful = true

# 连续碰撞伤害, 检测伤害接收器不来自damage_receiver
func on_emit_collateral_damage(receiver: DamageReceiver) -> void:
	if receiver != damage_receiver:
		# 重置方向，并发送一个伤害为0的击倒
		var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
		receiver.damage_received.emit(0, direction, DamageReceiver.HitType.KNOCKDOWN)

# 击飞到墙壁时
func on_wall_hit(wall: AnimatableBody2D) -> void:
	state = State.FALL
	height_speed = knockdown_intensity # 击到弹起高度
	velocity = -velocity / 2.0

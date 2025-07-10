class_name Character
extends CharacterBody2D

const GRAVITY := 600.0

@export var damage: int # 伤害值
@export var jump_intensity: int # 跳跃强度
@export var knockback_intensity : float # 击退强度
@export var knockdown_intensity : float # 击倒强度
@export var max_health: int # 最大生命值
@export var speed: float # 速度

# 加载完成后取得节点
@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var damage_emitter := $DamageEmitter # Area2D，检测区域
@onready var damage_receiver := $DamageReceiver

# 定义的状态
enum State {IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT, FALL, GROUNDED}

# 定义状态所对应动画名称
var anim_map := {
	State.IDLE: 'idle',
	State.WALK: 'walk',
	State.ATTACK: 'punch',
	State.TAKEOFF: 'takeoff',
	State.JUMP: 'jump',
	State.LAND: 'land',
	State.JUMPKICK: 'jumpkick',
	State.HURT: 'hurt',
	State.FALL: 'fall',
	State.GROUNDED: 'grounded',
}

var current_health := 0
var height := 0.0
var height_speed := 0.0
var state = State.IDLE # 默认状态

# 准备阶段
func _ready() -> void:
	# 当检测域有碰撞物体进入时，(area_entered)信号通过链接调用一个方法（on_emit_damage）
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	current_health = max_health # 初始化生命值

# 进程处理阶段
func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	handle_air_time(delta)
	fiip_sprites()
	character_sprite.position = Vector2.UP * height
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

# 动画事件，根据状态动画播放
func handle_animations() -> void:
	if animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])

# 空中时间，计算击退方式
func handle_air_time(delta: float) -> void:
	if [State.JUMP, State.JUMPKICK, State.FALL].has(state):
		height += height_speed * delta
		if height < 0:
			height = 0
			if state == State.FALL:
				state = State.GROUNDED
			else:
				state = State.LAND
		else:
			height_speed -= GRAVITY * delta

# 翻转角色左右
func fiip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
		damage_emitter.scale.x = 1
	elif velocity.x < 0:
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
	# 当前生命值计算， clamp限制生命值范围
	current_health = clamp(current_health - amount, 0, max_health)
	
	# 击倒判断
	if current_health == 0 or hit_type == DamageReceiver.HitType.KNOCKDOWN:
		state = State.FALL
		height_speed = knockdown_intensity # 击到弹起高度
	else:
		state = State.HURT
	velocity = direction * knockback_intensity

# 发射器 发送伤害，receiver为DamageReceiver类，此类下有一个信号(damage_received)，并过此信号发送伤害值息
func on_emit_damage(receiver: DamageReceiver) -> void:
	var hit_type := DamageReceiver.HitType.NORMAL
	# 三目运算，如果接收器器的位置<全局位置，则代表接收器的位置在左侧
	var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	if state == State.JUMPKICK:
		hit_type = DamageReceiver.HitType.KNOCKDOWN
	receiver.damage_received.emit(damage, direction, hit_type)

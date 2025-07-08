extends CharacterBody2D

@export var damage: int
@export var health: int
@export var speed: float

# 加载完成后取得节点
@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var damage_emitter: = $DamageEmitter

# 定义得的状态，并初始化态
enum State {IDLE, WALK, ATTACK}
var state = State.IDLE

# 准备阶段
func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())

# 进程处理阶段
func _process(_delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	fiip_sprites()
	move_and_slide()

# 移动事件
func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK
	else:
		velocity = Vector2.ZERO

# 按键事件
func handle_input() -> void:
		# 向量归1化移动
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed('attack'):
		state = State.ATTACK

# 动画事件，根据状态动画播放
func handle_animations() -> void:
	if state == State.IDLE:
		animation_player.play('idle')
	elif state == State.WALK:
		animation_player.play("walk")
	elif state == State.ATTACK:
		animation_player.play("punch")

# 翻转角色左右
func fiip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true

# 监听状态否可移动
func can_move() -> bool:
	return state == State.IDLE or state == State.WALK

# 监听状态否可攻击
func can_attack() -> bool:
	return state == State.IDLE or state == State.WALK

# 行动结束，状态重置
func on_aciton_complete() -> void:
	state = State.IDLE

func on_emit_damage(damage_receiver: Area2D) -> void:
	print(damage_receiver)

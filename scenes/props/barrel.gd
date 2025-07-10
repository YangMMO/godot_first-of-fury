extends StaticBody2D

@onready var damage_receiver := $DamageReceiver # 接收区域
@onready var sprite := $Sprite2D
@export var knockback_intensity : float # 受到击打 震退强度

const GRAVITY := 600.0 # 重力值

enum State {IDLE, DESTROYED}

var height := 0.0 # 击退的高度
var height_speed := 0.0 # 击退的高度速度
var state := State.IDLE
var veloctiy := Vector2.ZERO # 重力风速默认0

func _ready() -> void:
	# 当接收区域的(damage_received)信号接收信息时，会调用(on_receiv_damage)
	damage_receiver.damage_received.connect(on_receive_damage.bind())

func _process(delta: float) -> void:
	position += veloctiy * delta # 实时处理位置信息
	sprite.position = Vector2.UP * height  # 实时处理(精灵图)Y轴位置信息，模拟击飞高度抛物线
	handle_air_time(delta) # 此处才是真正计算受击行为

# 接收到伤害处理方法，此处不实际处理行为，仅处理变量
func on_receive_damage(_damage: int, direction: Vector2, hit_type:DamageReceiver.HitType) -> void:
	# 当只有默认态时，才会接收到伤害并处理
	if state == State.IDLE:
		sprite.frame = 1 # 变更精灵图
		height_speed = knockback_intensity * 2 # 计算物体受击时的高度速度
		state = State.DESTROYED # 变为摧毁状态
		veloctiy = direction * knockback_intensity #计算物体受击时的速度

# 空中时间，计算击退方式
func handle_air_time(delta: float) -> void:
	# 只有销毁状态，才会执行
	if state == State.DESTROYED:
		modulate.a -= delta # 变透明
		height += height_speed * delta # 击退的高度
		if height < 0: # 判断物体高度否<0
			height = 0
			queue_free() # 移除物体
		else: # 不小于0则重新计算击退的高度速度，根据重力值衰减
			height_speed -= GRAVITY * delta

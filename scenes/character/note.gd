extends CharacterBody2D

# 笔记

@export var health: int
@export var damage: int
@export var speed: float

# 当节点就绪时，才能取得到节点
#var animation_player
#func _ready() -> void:
	#animation_player = get_node('AnimationPlayer')

# 这种写法更简洁
@onready var animation_player := $AnimationPlayer

func _process(_delta: float) -> void:
	# 移动像素， * delta 控制帧数确保一致
	# 为什么不用这种，因为向量没有归1，当角色向左上、右上等四角动时，距离会不一致
	#if Input.is_action_pressed('ui_right'):
		#position += Vector2.RIGHT * _delta * speed
	#if Input.is_action_pressed('ui_left'):
		#position += Vector2.LEFT * _delta * speed
	#if Input.is_action_pressed('ui_up'):
		#position += Vector2.UP * _delta * speed
	#if Input.is_action_pressed('ui_down'):
		#position += Vector2.DOWN * _delta * speed

	# 向量归1化移动
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# 为什么不用这种，因为move_and_slide官方的api，velocity为速度，只需算速度，调用move_and_slide()即可
	#position += direction * _delta * speed
	velocity = direction * speed
	move_and_slide()

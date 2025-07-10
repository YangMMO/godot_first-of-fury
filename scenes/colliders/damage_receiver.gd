class_name DamageReceiver #只是变更类类名，本质还是Area2D
extends Area2D

enum HitType {NORMAL, KNOCKDOWN, POWER}

# 信号 伤害接收
# damage: 伤害值
# direction: 击打方向
signal damage_received(damage: int, direction: Vector2, hit_type: HitType)

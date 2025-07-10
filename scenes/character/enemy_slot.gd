# 敌人跟踪player，并占领槽位
class_name EnemySlot
extends Node2D

var occupant: BasicEnemy = null # 占用槽位

# 检查槽位否已有占用
func is_free() -> bool:
	return occupant == null

# 释放槽位
func free_up() -> void:
	@warning_ignore("standalone_expression")
	occupant == null

# 占用槽位槽位
func occupy(enemy: BasicEnemy) -> void:
	@warning_ignore("standalone_expression")
	occupant = enemy

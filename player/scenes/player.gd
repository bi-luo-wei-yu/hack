extends CharacterBody2D

#速度
const SPEED = 130
#攻击伤害
const ATTACK_DAMAGE = 100

#玩家属性
var is_attacking = false
var is_dead = false

@onready var animation_player = $AnimationPlayer
@onready var attack_area = $AttackArea
@onready var sprite = $Sprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction := Vector2.ZERO

#初始化状态
func _ready():
	attack_area.monitoring = false
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	direction = Vector2.ZERO
	
	# 方向输入
	if Input.is_action_pressed("上移"):
		direction.y -= 1
	if Input.is_action_pressed("下移"):
		direction.y += 1
	if Input.is_action_pressed("左移"):
		direction.x -= 1
	if Input.is_action_pressed("右移"):
		direction.x += 1

	# 归一化方向
	if direction != Vector2.ZERO:# 如果方向向量不是零向量（即有输入）
		direction = direction.normalized()# 归一化方向向量，保持方向不变但长度为1
		velocity = direction * SPEED# 根据方向和速度常量计算速度向量
		move_and_slide()# 调用内置函数，使角色平滑移动并处理碰撞
		update_animation(direction)# 根据移动方向更新动画
	else:
		velocity = Vector2.ZERO # 设置速度为零向量，角色停止移动
		animated_sprite.stop()	# 停止播放动画
		
	#攻击输入
	if Input.is_action_pressed("攻击") and not is_attacking and not is_dead:
		attack()

func attack():
	is_attacking = true
	animation_player.play("attack")
	
	# 启用攻击区域检测
	attack_area.monitoring = true
	
	# 根据朝向调整攻击区域位置
	adjust_attack_area()
	
	# 使用计时器在攻击结束后禁用区域
	await get_tree().create_timer(0.3).timeout
	attack_area.monitoring = false
	is_attacking = false
	
func adjust_attack_area():
	# 根据角色朝向调整攻击区域位置
	match animated_sprite.animation:
		"right":
			attack_area.position.x = 20
			attack_area.position.y = 0
		"left":
			attack_area.position.x = -20
			attack_area.position.y = 0
		"down":
			attack_area.position.x = 0
			attack_area.position.y = 20
		"up":
			attack_area.position.x = 0
			attack_area.position.y = -20
		_:  # 默认情况
			attack_area.position.x = 20
			attack_area.position.y = 0

# 当攻击区域检测到其他物体
func _on_attack_area_body_entered(body):
	# 确保只攻击敌人，联机逻辑
	print("击杀敌人")
				
# 死亡处理
func die():
	is_dead = true
	animation_player.play("death")
	# 禁用碰撞体
	$CollisionShape2D.set_deferred("disabled", true)
	
func update_animation(dir: Vector2) -> void:
	# 判断主方向（只使用 4 向动画）
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animated_sprite.play("right")
			if Input.is_action_pressed("攻击"):
				animated_sprite.play("right-gj")
		else:
			animated_sprite.play("left")
			if Input.is_action_pressed("攻击"):
				animated_sprite.play("left-gj")
	else:
		if dir.y > 0:
			animated_sprite.play("down")
			if Input.is_action_pressed("攻击"):
				animated_sprite.play("down-gj")
		else:
			animated_sprite.play("up")
			if Input.is_action_pressed("攻击"):
				animated_sprite.play("up-gj")

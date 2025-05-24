extends Area2D

@onready var timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	body.get_node("CollisionShape2D").queue_free()# Replace with function body.

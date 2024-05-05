extends Area2D

var damage = 1

func _on_body_entered(body: Node2D) -> void:
	SignalBus.emit_signal("hurt_player")


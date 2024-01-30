class_name BulletToPoint extends ControlLeaf


@onready var cache_key = 'bullet_to_point_%s' % self.get_instance_id()


func tick(actor: Node, blackboard: Blackboard) -> int:
	return 0


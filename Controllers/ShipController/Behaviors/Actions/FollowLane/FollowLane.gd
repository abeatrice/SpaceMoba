@tool
extends ActionLeaf

enum MoveDirection {
	TOWARD_ENEMY = 0,
	AWAY_FROM_ENEMY = 1,
}

@export var look_ahead_distance: float = 200.0
@export var move_direction: MoveDirection = MoveDirection.TOWARD_ENEMY

@export var max_lateral_offset: float = 60.0
@export var wobble_speed: float = 2.0
@export var wobble_strength: float = 15.0

var _time: float = 0.0
var _random_lane_side: float = 1.0

func _ready():
	_random_lane_side = 1.0 if randf() > 0.5 else -1.0
	_time = randf() * 10.0

func tick(actor, _blackboard: Blackboard):
	_time += get_process_delta_time()

	var ship_controller = actor as ShipController
	if not ship_controller.ship: return FAILURE

	var ship = ship_controller.ship as Ship
	
	var path: Path2D = ship_controller.assigned_lane
	if not path: return FAILURE

	var curve = path.curve
	var current_offset = curve.get_closest_offset(ship.global_position)
	
	var target_offset = 0.0
	var is_team_a = ship.team_component.team == TeamComponent.Team.A
	var move_toward_enemy = move_direction == MoveDirection.TOWARD_ENEMY
	if is_team_a && move_toward_enemy:
		target_offset = current_offset + look_ahead_distance
	elif not is_team_a && not move_toward_enemy:
		target_offset = current_offset + look_ahead_distance
	else: 
		target_offset = current_offset - look_ahead_distance

	var target_pos = curve.sample_baked(target_offset)
	
	var next_point = curve.sample_baked(current_offset + 1.0)
	var lane_direction = (next_point - target_pos).normalized()
	
	var perpendicular = Vector2(-lane_direction.y, lane_direction.x)
	
	var lateral_shift = (max_lateral_offset * _random_lane_side)
	lateral_shift += sin(_time * wobble_speed) * wobble_strength
	
	target_pos += perpendicular * lateral_shift
	
	ship_controller.move_to_pos(target_pos)
	return RUNNING

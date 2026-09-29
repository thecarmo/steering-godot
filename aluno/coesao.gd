extends Node

func calcular(agente) -> Vector2:
	if agente.vizinhos.is_empty():
		return Vector2.ZERO
	var centro = Vector2.ZERO
	for vizinho in agente.vizinhos:
		centro += vizinho.global_position
	centro /= agente.vizinhos.size()
	return $Seek.para(agente, centro)

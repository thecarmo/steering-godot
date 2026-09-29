extends Node

func calcular(agente) -> Vector2:
	if agente.vizinhos.is_empty():
		return Vector2.ZERO
	var media = Vector2.ZERO
	for vizinho in agente.vizinhos:
		media += vizinho.velocity
	media /= agente.vizinhos.size()
	return media - agente.velocity

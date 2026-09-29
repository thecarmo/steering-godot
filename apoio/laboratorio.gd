extends Node2D

const AGENTE = preload("res://cenas/agente.tscn")
const NOMES = ["Seek", "Arrive", "Pursuit", "Flocking", "Cancelamento", "Parede"]
var agentes: Array = []
var modo: int = 1
var pausado: bool = false

func _ready() -> void:
	preparar(1)

func preparar(numero: int) -> void:
	modo = numero
	pausado = false
	for agente in agentes:
		remove_child(agente)
		agente.queue_free()
	agentes.clear()
	$Alvo.position = Vector2(880, 350)
	$Alvo.velocity = Vector2.ZERO
	$Alvo.visible = modo != 4
	$Parede.visible = modo == 6
	for trecho in $Parede.get_children():
		trecho.collision_layer = 1 if modo == 6 else 0
	if modo == 3:
		$Alvo.position = Vector2(250, 230)
		$Alvo.velocity = Vector2(100, 0)
	for i in range(48 if modo == 4 else 1):
		var agente = AGENTE.instantiate()
		add_child(agente)
		agentes.append(agente)
		agente.position = Vector2(200, 440 if modo == 3 else 350)
		agente.alvo = $Alvo
		var nome = NOMES[modo - 1] if modo != 6 else "Arrive"
		agente.estrategia = agente.get_node("Direcoes/" + nome)
		if modo == 4:
			agente.position = Vector2(140 + (i % 8) * 115, 180 + (i / 8) * 66)
			agente.velocity = Vector2.RIGHT.rotated(i * 2.4) * 70.0
			agente.velocidade_max = 110.0
			agente.forca_max = 180.0
			agente.collision_mask = 0
			agente.get_node("Visual/Velocidade").visible = false
			agente.get_node("Visual/Forca").visible = false
	if modo == 6:
		agentes[0].position = Vector2(450, 350)
		$Alvo.position = Vector2(850, 350)
	atualizar_painel()

func _physics_process(delta: float) -> void:
	if pausado:
		return
	$Alvo.mover(delta)
	$Grade.reconstruir(agentes)
	for agente in agentes:
		agente.vizinhos = $Grade.consultar(agente) if modo == 4 else []
		agente.forca = agente.estrategia.calcular(agente)
	for agente in agentes:
		agente.mover(delta)
		if modo == 4:
			agente.position.x = wrapf(agente.position.x, 80.0, 1072.0)
			agente.position.y = wrapf(agente.position.y, 150.0, 590.0)
	atualizar_painel()

func atualizar_painel() -> void:
	$Interface/Titulo.text = "STEERING BEHAVIOUR   /   " + NOMES[modo - 1]
	var agente = agentes[0]
	$Interface/Dados.text = "Rapidez: %3.0f px/s    Força: %3.0f    Agentes: %d" % [agente.velocity.length(), agente.forca.limit_length(agente.forca_max).length(), agentes.size()]
	if modo == 4:
		$Interface/Dados.text += "    Candidatos: %d / %d" % [$Grade.candidatos, agentes.size() * (agentes.size() - 1)]
	$Interface/Ajuda.text = "Clique: mover alvo    R: reiniciar cenário    Espaço: pausar    Azul: velocidade    Laranja: força"
	if modo == 4:
		$Interface/Ajuda.text = "48 boids / vizinhos até 100 px / pesos no nó Direcoes/Flocking / bordas com reaparecimento"
	if pausado:
		$Interface/Titulo.text += " (pausado)"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_6:
			preparar(event.keycode - KEY_0)
		elif event.keycode == KEY_R:
			preparar(modo)
		elif event.keycode == KEY_SPACE:
			pausado = not pausado
			atualizar_painel()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and modo in [1, 2, 5]:
		$Alvo.position = get_global_mouse_position().clamp(Vector2(80, 150), Vector2(1072, 590))

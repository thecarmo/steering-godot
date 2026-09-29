extends Node

@export var etapa: int = 3
signal terminou(falhas: int)
var total := 0
var falhas := 0
var painel: Label
var cena: Node2D

func _ready() -> void:
	painel = Label.new()
	painel.position = Vector2(40, 24)
	painel.add_theme_color_override("font_color", Color("17334a"))
	painel.add_theme_font_size_override("font_size", 23)
	add_child(painel)
	painel.text = "Verificando etapa %d..." % etapa
	call_deferred("executar")

func conferir(nome: String, passou: bool) -> void:
	total += 1
	if not passou:
		falhas += 1
	print(("OK: " if passou else "FALHA: ") + nome)

func quadros(n: int) -> void:
	for i in range(n):
		await get_tree().physics_frame
		await get_tree().process_frame

func tecla(numero: int) -> void:
	var evento := InputEventKey.new()
	evento.keycode = KEY_0 + numero
	evento.pressed = true
	cena._unhandled_input(evento)

func calcular(nome: String, agente) -> Vector2:
	return agente.get_node("Direcoes/" + nome).calcular(agente)

func base() -> void:
	cena = load("res://cenas/laboratorio.tscn").instantiate()
	add_child(cena)
	cena.set_physics_process(false)
	cena.set_process_unhandled_input(false)
	var a = cena.agentes[0]
	conferir("corpo e colisão nativos", a is CharacterBody2D and a.get_node("Colisao") is CollisionShape2D)
	conferir("estratégias usam a mesma interface", a.estrategia.has_method("calcular"))
	a.velocity = Vector2.ZERO
	a.forca = Vector2(10000, 0)
	a.mover(1.0 / 60.0)
	conferir("força limita aceleração", a.velocity.length() <= a.forca_max / 60.0 + 0.01)
	a.velocity = Vector2(180, 0)
	a.mover(1.0 / 60.0)
	conferir("rapidez respeita teto", a.velocity.length() <= a.velocidade_max + 0.01)
	a.forca = Vector2(60, 0)
	a.velocity = Vector2.ZERO
	a.mover(0.1)
	var v1 = a.velocity.x
	a.velocity = Vector2.ZERO
	a.mover(0.05)
	a.mover(0.05)
	conferir("integração de força constante usa delta", is_equal_approx(v1, a.velocity.x))
	for n in range(1, 7):
		tecla(n)
		conferir("controle %d seleciona cenário" % n, cena.modo == n and cena.agentes.size() == (48 if n == 4 else 1))
	tecla(1)
	var clique := InputEventMouseButton.new()
	clique.button_index = MOUSE_BUTTON_LEFT
	clique.pressed = true
	cena._unhandled_input(clique)
	conferir("clique mantém alvo na arena", Rect2(80, 150, 993, 441).has_point(cena.get_node("Alvo").position))
	var pausa := InputEventKey.new()
	pausa.keycode = KEY_SPACE
	pausa.pressed = true
	cena._unhandled_input(pausa)
	conferir("pausa responde ao teclado", cena.pausado)
	cena._unhandled_input(pausa)
	conferir("teclado retoma movimento", not cena.pausado)
	tecla(4)
	var grade = cena.get_node("Grade")
	cena.agentes[0].position = Vector2(-1, -1)
	cena.agentes[1].position = Vector2(-101, -1)
	cena.agentes[2].position = Vector2(0, 0)
	grade.reconstruir(cena.agentes)
	var igual := true
	for agente in cena.agentes:
		var obtidos = grade.consultar(agente)
		var esperados: Array = []
		for outro in cena.agentes:
			if outro != agente and agente.position.distance_squared_to(outro.position) < 10000:
				esperados.append(outro)
		igual = igual and obtidos.size() == esperados.size()
		for outro in esperados:
			igual = igual and obtidos.has(outro)
	conferir("grade coincide com busca completa, inclusive bordas e negativos", igual)
	conferir("grade reduz candidatos no cenário distribuído", grade.candidatos < 48 * 47)

func seek() -> void:
	tecla(1)
	var a = cena.agentes[0]
	a.position = Vector2(100, 200)
	a.alvo.position = Vector2(400, 200)
	a.velocity = Vector2(30, 0)
	conferir("Seek aponta para alvo e desconta velocidade", calcular("Seek", a).is_equal_approx(Vector2(150, 0)))
	a.alvo.position = a.position
	conferir("Seek no alvo freia sem NaN", calcular("Seek", a).is_equal_approx(Vector2(-30, 0)))
	a.alvo.position = Vector2(100, 500)
	a.velocity = Vector2.ZERO
	conferir("Seek trata direção vertical", calcular("Seek", a).is_equal_approx(Vector2(0, 180)))
	tecla(1)
	cena.set_physics_process(true)
	await quadros(60)
	a = cena.agentes[0]
	conferir("Seek movimenta a cena real", a.position.x > 240 and a.velocity.x > 60)
	var ultrapassou := false
	for i in range(600):
		await quadros(1)
		ultrapassou = ultrapassou or a.position.x > a.alvo.position.x + 10
	conferir("Seek ultrapassa alvo fixo", ultrapassou)
	tecla(5)
	await quadros(120)
	a = cena.agentes[0]
	conferir("forças opostas deixam agente parado", a.position.distance_to(Vector2(200, 350)) < 0.01 and a.forca.length() < 0.01)
	cena.set_physics_process(false)

func individuais() -> void:
	tecla(2)
	var a = cena.agentes[0]
	a.position = Vector2(100, 350)
	a.alvo.position = Vector2(230, 350)
	a.velocity = Vector2.ZERO
	conferir("Arrive reduz rapidez dentro do raio", calcular("Arrive", a).is_equal_approx(Vector2(90, 0)))
	a.alvo.position = Vector2(700, 350)
	conferir("Arrive limita rapidez fora do raio", calcular("Arrive", a).is_equal_approx(Vector2(180, 0)))
	a.alvo.position = a.position
	a.velocity = Vector2(40, -20)
	conferir("Arrive no alvo freia sem divisão por zero", calcular("Arrive", a).is_equal_approx(Vector2(-40, 20)))
	tecla(2)
	cena.set_physics_process(true)
	await quadros(1200)
	a = cena.agentes[0]
	conferir("Arrive converge em 20 segundos", a.position.distance_to(a.alvo.position) < 2.0 and a.velocity.length() < 1.0)
	await quadros(120)
	conferir("Arrive permanece próximo do alvo", a.position.distance_to(a.alvo.position) < 2.0)
	cena.set_physics_process(false)
	tecla(3)
	a = cena.agentes[0]
	a.position = Vector2(400, 400)
	a.alvo.position = Vector2(400, 220)
	a.alvo.velocity = Vector2(100, 0)
	a.velocity = Vector2.ZERO
	var f: Vector2 = calcular("Pursuit", a)
	conferir("Pursuit antecipa deslocamento lateral", f.x > 80 and f.y < -140)
	a.alvo.velocity = Vector2.ZERO
	conferir("Pursuit de alvo parado equivale a Seek", calcular("Pursuit", a).is_equal_approx(calcular("Seek", a)))
	a.alvo.position = Vector2(400, -1400)
	a.alvo.velocity = Vector2(100, 0)
	conferir("Pursuit limita previsão a 1,5 segundo", calcular("Pursuit", a).is_equal_approx(Vector2(150, -1800).normalized() * 180))
	tecla(3)
	cena.set_physics_process(true)
	var menor := 10000.0
	for i in range(600):
		await quadros(1)
		a = cena.agentes[0]
		menor = minf(menor, a.position.distance_to(a.alvo.position))
	conferir("Pursuit alcança proximidade do alvo móvel", menor < 20)
	tecla(6)
	await quadros(600)
	a = cena.agentes[0]
	conferir("parede nativa bloqueia passagem", a.position.x < 609 and a.position.x > 590 and a.velocity.length() < 1.0)
	conferir("steering não acha saída da concavidade", a.position.distance_to(a.alvo.position) > 200)
	cena.set_physics_process(false)

func grupos() -> void:
	tecla(4)
	var a = cena.agentes[0]
	var outro = cena.agentes[1]
	a.position = Vector2(300, 300)
	a.velocity = Vector2.ZERO
	a.vizinhos = []
	for nome in ["Separacao", "Alinhamento", "Coesao"]:
		conferir(nome + " sem vizinhos retorna zero", calcular("Flocking/" + nome, a) == Vector2.ZERO)
	a.vizinhos = [outro]
	outro.position = Vector2(320, 300)
	outro.velocity = Vector2(0, 70)
	conferir("separação repele vizinho próximo", calcular("Flocking/Separacao", a).x < -100)
	conferir("alinhamento busca velocidade média", calcular("Flocking/Alinhamento", a).is_equal_approx(Vector2(0, 70)))
	conferir("coesão busca centro dos vizinhos", calcular("Flocking/Coesao", a).x > 100)
	outro.position = Vector2(360, 300)
	conferir("separação respeita raio menor", calcular("Flocking/Separacao", a) == Vector2.ZERO)
	outro.position = a.position
	conferir("posições coincidentes mantêm força finita", calcular("Flocking/Separacao", a).is_finite())
	outro.position = Vector2(320, 300)
	var misturador = a.get_node("Direcoes/Flocking")
	var original: Vector2 = calcular("Flocking", a)
	misturador.peso_separacao = 0.0
	conferir("peso altera força combinada", calcular("Flocking", a).x > original.x + 100)
	misturador.peso_alinhamento = 0.0
	misturador.peso_coesao = 0.0
	conferir("pesos zero desligam regras", calcular("Flocking", a) == Vector2.ZERO)
	tecla(4)
	cena.set_physics_process(true)
	var posicao: Vector2 = cena.agentes[0].position
	var velocidade: Vector2 = cena.agentes[0].velocity
	await quadros(600)
	var saudaveis := true
	for agente in cena.agentes:
		saudaveis = saudaveis and agente.position.is_finite() and agente.velocity.is_finite()
		saudaveis = saudaveis and agente.velocity.length() <= 110.01
		saudaveis = saudaveis and Rect2(80, 150, 993, 441).has_point(agente.position)
	conferir("48 boids permanecem finitos, limitados e na arena", saudaveis and cena.agentes.size() == 48)
	conferir("flocking movimenta os agentes", cena.agentes[0].position.distance_to(posicao) > 10)
	conferir("vizinhos mudam a direção de movimento", cena.agentes[0].velocity.distance_to(velocidade) > 10)
	cena.set_physics_process(false)

func executar() -> void:
	await base()
	if etapa >= 1:
		await seek()
	if etapa >= 2:
		await individuais()
	if etapa >= 3:
		await grupos()
	cena.free()
	painel.text = "Etapa %d: %d/%d verificações passaram." % [etapa, total - falhas, total]
	print("RESULTADO: " + painel.text)
	terminou.emit(falhas)

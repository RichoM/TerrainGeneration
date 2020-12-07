extends Spatial

const max_chunks_per_frame = 1
const chunk_size = 64
var chunk_amount = 4

var noise
var chunks = {}
var unready_chunks = {}

func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 6
	noise.period = 80

	
func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key): return false
	load_chunk(x, z)
	return true
		
func load_chunk(x, z):
	var chunk = Chunk.new(noise, x * chunk_size, z * chunk_size, chunk_size)
	chunk.translation = Vector3(x * chunk_size, 0, z * chunk_size)
	load_done(chunk)
	
func load_done(chunk):
	var key = str(chunk.x / chunk_size) + "," + str(chunk.z / chunk_size)
	chunks[key] = chunk
	add_child(chunk)
	
func get_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key):
		return chunks.get(key)
	return null
	
func _process(delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()
	
func update_chunks():
	var player_translation = $Player.translation
	var p_x = int(player_translation.x) / chunk_size
	var p_z = int(player_translation.z) / chunk_size
	
	var chunks_added = 0
	for x in range(p_x - chunk_amount * 0.5, p_x + chunk_amount * 0.5):
		for z in range(p_z - chunk_amount * 0.5, p_z + chunk_amount * 0.5):
			if chunks_added < max_chunks_per_frame and add_chunk(x, z):
				chunks_added += 1
			var chunk = get_chunk(x, z)
			if chunk != null:
				chunk.should_remove = false
					
				
	if chunks_added == 0 and chunk_amount < 16:
		chunk_amount = chunk_amount * 2
	
func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)
	
func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true

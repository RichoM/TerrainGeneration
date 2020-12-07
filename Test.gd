extends Spatial


func _ready():
	var noise = OpenSimplexNoise.new()
	var ch = Chunk.new(noise, 2, 3, 200)
	add_child(ch)

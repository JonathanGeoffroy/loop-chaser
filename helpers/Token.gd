extends Node

const OBFUSCATION_KEY: Array[int] = [0x53, 0x4B, 0x47, 0x4A, 0x41, 0x4D, 0x32, 0x30, 0x32, 0x36]  # "SKGJAM2026"


func serialize(seed: int, score: int, username: String) -> String:
	var buffer := StreamPeerBuffer.new()
	buffer.big_endian = true
	buffer.put_64(seed)
	buffer.put_32(score)

	var obfuscated_bytes := _xor_transform(buffer.data_array, OBFUSCATION_KEY)
	
	# Godot 4 method to convert PackedByteArray to Hex String
	var hex_data: String = obfuscated_bytes.hex_encode()
	
	var clean_username: String = username.strip_edges().replace(":", "").replace("?", "").replace("&", "")

	return clean_username + ":" + hex_data


func deserialize(payload: String) -> TokenValue:
	var parts: PackedStringArray = payload.split(":", true, 1)
	if parts.size() < 2:
		return null

	var username: String = parts[0]
	var hex_str: String = parts[1]

	# Parse hex string back to PackedByteArray
	var obfuscated_bytes := _hex_to_bytes(hex_str)

	if obfuscated_bytes.size() < 12:
		return null

	var raw_bytes := _xor_transform(obfuscated_bytes, OBFUSCATION_KEY)

	var buffer := StreamPeerBuffer.new()
	buffer.big_endian = true
	buffer.data_array = raw_bytes

	var seed: int = buffer.get_64()
	var score: int = buffer.get_32()

	var token := TokenValue.new()
	token.username = username
	token.seed = seed
	token.score = score
	return token


func _xor_transform(bytes: PackedByteArray, key: Array[int]) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(bytes.size())

	var key_length: int = key.size()
	for i in range(bytes.size()):
		result[i] = bytes[i] ^ key[i % key_length]

	return result


# Helper function to convert Hex String -> PackedByteArray
func _hex_to_bytes(hex: String) -> PackedByteArray:
	var bytes := PackedByteArray()
	if hex.length() % 2 != 0:
		return bytes
		
	bytes.resize(hex.length() / 2)
	for i in range(bytes.size()):
		var byte_hex := hex.substr(i * 2, 2)
		bytes[i] = ("0x" + byte_hex).hex_to_int()
		
	return bytes

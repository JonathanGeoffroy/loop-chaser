extends Node

const OBFUSCATION_KEY: Array[int] = [0x53, 0x4B, 0x47, 0x4A, 0x41, 0x4D, 0x32, 0x30, 0x32, 0x36]  # "SKGJAM2026"


func serialize(seed: int, score: int, username: String) -> String:
	var buffer := StreamPeerBuffer.new()
	buffer.big_endian = true
	buffer.put_64(seed)
	buffer.put_32(score)

	var obfuscated_bytes := _xor_transform(buffer.data_array, OBFUSCATION_KEY)
	var b64_data: String = Marshalls.raw_to_base64(obfuscated_bytes)
	var clean_b64: String = b64_data.replace("+", "-").replace("/", "_").replace("=", "")
	var clean_username: String = username.strip_edges().replace(":", "").replace("?", "").replace(
		"&", ""
	)

	return clean_username + ":" + clean_b64


func deserialize(payload: String) -> TokenValue:
	var parts: PackedStringArray = payload.split(":", true, 1)
	if parts.size() < 2:
		return null

	var username: String = parts[0]
	var obfuscated_str: String = parts[1]

	var b64_str: String = obfuscated_str.replace("-", "+").replace("_", "/")
	var mod: int = b64_str.length() % 4
	if mod > 0:
		b64_str += "=".repeat(4 - mod)

	var obfuscated_bytes: PackedByteArray = Marshalls.base64_to_raw(b64_str)

	if obfuscated_bytes.size() < 12:
		return null

	var raw_bytes := _xor_transform(obfuscated_bytes, OBFUSCATION_KEY)

	var buffer := StreamPeerBuffer.new()
	buffer.big_endian = true
	buffer.data_array = raw_bytes

	var seed: int = buffer.get_64()
	var score: int = buffer.get_32()

	var token := TokenValue.new()
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

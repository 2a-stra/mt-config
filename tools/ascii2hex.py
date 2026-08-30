#!/usr/bin/python3
import sys

#ascii_text = sys.argv[1]

# ASCII string to encode
ascii_text = "http://192.168.1.100:8000/config"

# Encode to bytes using ASCII
byte_data = ascii_text.encode("ascii")

# Convert bytes to hex string
hex_string = byte_data.hex()

#print(ascii_text)
print("0x%s" % hex_string)

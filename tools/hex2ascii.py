#!/usr/bin/python3

hex_string = "687474703a2f2f3139322e3136382e312e3130303a383030302f636f6e666967"

# Convert hex string to bytes
byte_data = bytes.fromhex(hex_string)

# Decode to ASCII, replacing non-printable characters
ascii_text = byte_data.decode("ascii", errors="replace")

print(hex_string)
print(ascii_text)
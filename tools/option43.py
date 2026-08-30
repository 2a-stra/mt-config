#!/usr/bin/python3
'''
Generate hex string for DHCP Option43 and 66

Source:
https://github.com/2a-stra/mt-config
'''
import sys

ascii_text = sys.argv[1]
#ascii_text = "http://192.168.1.100:8000/config"

print(ascii_text)

a = bytes(ascii_text, "utf8")
ax = a.hex()
l = len(a)
lx = hex(l)[2:]

if len(lx) == 1:
    lx = "0" + lx

out = f'''
(T)ype = "02"
(L)en = {lx} ({l} bytes)
(V)alue = {ax}
TLV:
0x02{lx}{ax}
'''

print(out)

print(f'CODE43 = "0x02{lx}{ax}"')
print(f'CODE66 = "0x{ax}"')

# Z10 Switch-3

Device: EdgeSwitch

Port | VLAN | PoE | device                     | comment
-----|------|-----|----------------------------|--------
   1 | 11   | on  | bridge-z10-db0hro          |  
   2 | 12   | on  | reserved for bridge        |
   3 | 13   | on  | reserved for bridge        |
   4 |  1   | on  | reserved for mesh node     |
   5 |  1   | on  | reserved for mesh node     |
   6 |  1   | on  | reserved for mesh node     |
   7 |  1   | on  | reserved for mesh node     |
   8 |  1   | off | -                          | for management access |
   9 | 1-50 | off | EdgeRouter-X               | trunk port
  10 | 1-50 | off | (reserved) another switch  | trunk

# Installation

EdgeSwitch 10XP

Native firmware: v1.3.1

User: ubnt
Pwd: Standardpasswort 2x concatenated

Device name: switch-z10-3

IP 192.168.5.58/16 ; GW: 192.168.5.56

ID | Name   |Port 1 .. 10
---|--------|------------
1  | default|EEEU UUUU TT
11 | VLAN 11|UEEE EEEE TT
12 | VLAN 12|EUEE EEEE TT
13 | VLAN 13|EEUE EEEE TT

* U untagged - T tagged - E exclude

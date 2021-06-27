# Z10 Switch-3

Device: EdgeSwitch

Port | VLAN | PoE | device                     | comment
-----|------|-----|----------------------------|--------
   1 |  1   | on  | reserved for mesh node     |  
   2 |  1   | on  | reserved for mesh node     |
   3 |  1   | on  | reserved for mesh node     |
   4 |  1   | on  | reserved for mesh node     |
   5 |  1   | on  | reserved for mesh node     |
   6 |  1   | on  | reserved for mesh node     |
   7 |  1   | on  | reserved for mesh node     |
   8 |  1   | off | reserved for non PoE device| e.g. management access |
   9 | 1-50 | off | res. EdgeRouter-X          | trunk port
  10 | 1-50 | off | another switch             | trunk port

# Installation

EdgeSwitch 10XP

Native firmware: v1.1.0

User: ubnt
Pwd: Standardpasswort 2x concatenated

Device name: switch-z10-4

IP 192.168.5.57/16 ; GW: 192.168.5.56

ID | Name   |Port 1 .. 10
---|--------|------------
1  | default|UUUU UUUU TT

* U untagged - T tagged - E exclude

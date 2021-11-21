# DB0HRO Switch

Device: ToughSwitch

Port | VLAN | PoE | device                     | comment
-----|------|-----|----------------------------|--------
 Mgmt|  1   | -   |                            |
   1 | 51   | on  | bridge-z10                 |  
   2 | 51   | off | ER-X bridge z10            |
   3 | 52   | on  | bridge-wrnmde              |
   4 | 52   | off | ER-X bridge-wrnmde         |
   5 |  1   | off | reserved                   |

 
# Installation

Ubnt ToughSwitch

Native firmware: SW.v1.3.2

User: admin
Pwd: ($standard)

Device name: switch-db0hro-poe

IP 192.168.5.56/16 ; GW: -

ID | Name   |Port 1 .. 5
---|--------|------------
1  | Mgmt   |EEEEU
51 | VLAN 51|UUEEE
52 | VLAN 52|EEUUE

* U untagged - T tagged - E exclude
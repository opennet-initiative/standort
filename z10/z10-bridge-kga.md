# Hardware

* Model: Mikrotik mANTBox 15s
* OS: RouterOS 6.49.5

# Configuration

for configuration steps see https://opennet-initiative.de/wiki/MikroTik_RouterBoard#Configure_with_native_RouterOS_firmware

Location:    | Z10
-------------|-----------------------
Hostname:    | AP5.22
Password:    | ...
IP:          | 192.168.5.22
Netmask:     | 255.255.0.0
Default Gw:  | 192.168.21.245 (Mesh neighbour)
DNS:         | 192.168.0.247
NTP:         | 192.168.0.247
Syslog:      | -
Mode:        | *ap bridge*
SSID:        | Z10-KGA.on-i.de
Frequency:   | auto
ChanWidth:   | 20
Country:     | germany
Installation:| outdoor

[1] Note: Depending on RouterOS license the mode "PTP Bridge AP" enables one peer (license level 3) or many peers  (license level 4) to connect. mANTBox has license level 4.
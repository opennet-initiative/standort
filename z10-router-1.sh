#we assume Opennet Firmware 0.5.6-stable is installed on ER-X router

#
# In the following you find the configuration of this device.
#

# connect to eth1 for management access (dhcp)
# connect Internet line to eth0 (for downloading packages)

# change root password
passwd

# set IP
on-function set_opennet_id 1.245

# install monitoring (we need Internet connection for this step, therefore connect port eth0 to Internet)
opkg-oni install on-monitoring on-goodies tcpdump-mini

# as of today (May 2021) olsrd2 is always deactivated by default. We enable it.
on-function enable_on_module on-olsr2
# we need Internet for LoRaWan
on-function enable_on_module on-openvpn


# ER-X has the following ports:
# eth0 = WAN
# eth1 = LAN1
# eth2 = LAN2
# eth3 = LAN3
# eth4 = LAN4

# Possibly there will be many access points in this location with native
# firmware. These devices work in bridge mode.
# Every bridge needs to be terminated by a mesh node (router).
# For Z10 we will have at least one router which connects all bridges together.

# For every bridge we will have:
# - a VLAN number (configured on switch and router), because bridge needs an
#   isolated network connecting to router
# - a PoE port on the switch with specific VLAN (untagged)
# - a mesh interface/VLAN on the router

#
# ER-X settings
#
# View by VLAN
#
# VLAN ID| VLAN Name (IP)          | phy. interface | description
# -------|-------------------------|----------------|------------
#      99| br-lan (172.16.0.1/24)  | LAN3+LAN4      | use for management access
#       1| on_eth_0 (192.168.1.245)| WAN+LAN1+LAN2  | general mesh VLAN
#      11| on_eth_1 (192.168.11.245)| WAN            | connect one single bridge
#      12| on_eth_2 (192.168.21.245)| WAN            | connect one single bridge
#      13| on_eth_3 (192.168.31.245)| WAN            | connect one single bridge
#
# WAN (eth0) is tagged with all VLANs except VLAN 99.
# All other ports are untagged.

#
# EdgeSwitch
#  IP 192.168.5.58/16 ; GW: 192.168.1.245 ; VLAN: 1
#
# Port | VLAN | device               | comment
# -----|------|----------------------|--------
#    1 | 11   | bridge-z10-db0hro    |
#    2 | 12   | reserved for bridge  |
#    3 | 13   | reserved for bridge  |
#    4 |  1   | general mesh network |
#    5 |  1   | general mesh network |
#    6 |  1   | general mesh network |
#    7 |  1   | general mesh network |
#    8 | 1-50 | EdgerRouter-X        | trunk port to EdgeRouter-X


#configure switching
# VLAN 1 (preconfigured) -> VLAN 99
#       network.@switch_vlan[0]=switch_vlan
#       network.@switch_vlan[0].device='switch0'
#       network.@switch_vlan[0].vlan='1'
uci set network.@switch_vlan[0].vid='99'  # change default VLAN ID for LAN
uci set network.@switch_vlan[0].ports='3 4 6t'
uci set network.lan.ifname='eth0.99'  # VLAN 1 is part of lan bridge therefore we need to change this too
# VLAN 2 (preconfigured) -> VLAN 1
#       network.@switch_vlan[1]=switch_vlan
#       network.@switch_vlan[1].device='switch0'
#       network.@switch_vlan[1].vlan='2'
uci set network.@switch_vlan[1].ports='0t 1 2 6t'  # transport all mesh VLANs on phy. port eth0/WAN
uci set network.@switch_vlan[1].vid='1'  # change default VLAN ID
# VLAN 11 (new)
uci add network switch_vlan
uci set network.@switch_vlan[2].device='switch0'
uci set network.@switch_vlan[2].vlan='3'
uci set network.@switch_vlan[2].ports='0t 6t'  # transport all mesh VLANs on phy. port eth0/WAN
uci set network.@switch_vlan[2].vid='11'
# VLAN 12 (new)
uci add network switch_vlan
uci set network.@switch_vlan[3].device='switch0'
uci set network.@switch_vlan[3].vlan='4'
uci set network.@switch_vlan[3].ports='0t 6t'  # transport all mesh VLANs on phy. port eth0/WAN
uci set network.@switch_vlan[3].vid='12'
# VLAN 13 (new)
uci add network switch_vlan
uci set network.@switch_vlan[4].device='switch0'
uci set network.@switch_vlan[4].vlan='5'
uci set network.@switch_vlan[4].ports='0t 6t'  # transport all mesh VLANs on phy. port eth0/WAN
uci set network.@switch_vlan[4].vid='13'


#fix zones-interface association
#reset zone wan
uci set network.wan.ifname='none'
#reset zone wan6
uci set network.wan6.ifname='none'
uci set network.wan6.reqaddress='try'
uci set network.wan6.reqprefix='auto'

#assign on_eth_0 to VLAN
uci set network.on_eth_0.ifname='eth0.1'
#assign on_eth_1 to VLAN
uci set network.on_eth_1.ifname='eth0.11'

#create and configure on_eth_2
ON_ID=2
uci set network.on_eth_${ON_ID}=interface
uci set network.on_eth_${ON_ID}.proto='static'
uci set network.on_eth_${ON_ID}.netmask='255.255.0.0'
uci set network.on_eth_${ON_ID}.defaultroute='0'
uci set network.on_eth_${ON_ID}.peerdns='0'
uci set network.on_eth_${ON_ID}.ifname="eth0.1${ON_ID}"
uci set network.on_eth_${ON_ID}.ipaddr="192.168.${ON_ID}1.245"

uci add_list firewall.@zone[2].network="on_eth_${ON_ID}"

uci add olsrd Interface
uci set olsrd.@Interface[-1].interface="on_eth_${ON_ID}"
uci set olsrd.@Interface[-1].ignore='0'

uci add_list olsrd2.@interface[0].name="on_eth_${ON_ID}"

#create and configure on_eth_3
ON_ID=3
uci set network.on_eth_${ON_ID}=interface
uci set network.on_eth_${ON_ID}.proto='static'
uci set network.on_eth_${ON_ID}.netmask='255.255.0.0'
uci set network.on_eth_${ON_ID}.defaultroute='0'
uci set network.on_eth_${ON_ID}.peerdns='0'
uci set network.on_eth_${ON_ID}.ifname="eth0.1${ON_ID}"
uci set network.on_eth_${ON_ID}.ipaddr="192.168.${ON_ID}1.245"

uci add_list firewall.@zone[2].network="on_eth_${ON_ID}"

uci add olsrd Interface
uci set olsrd.@Interface[-1].interface="on_eth_${ON_ID}"
uci set olsrd.@Interface[-1].ignore='0'

uci add_list olsrd2.@interface[0].name="on_eth_${ON_ID}"


#
# make connected non-OLSR devices available in mesh network
#

# EdgeSwitch - 192.168.5.58/16 ; GW: 192.168.1.245 ; VLAN: 1
DEVICE_NAME="switch-z10-3"
DEVICE_IP="192.168.5.58"
ON_IF="on_eth_0"
ON_IF_IP="192.168.1.245"
uci add olsrd Hna4
uci set olsrd.@Hna4[-1].netmask='255.255.255.255'
uci set olsrd.@Hna4[-1].netaddr="${DEVICE_IP}"
uci add network route
uci set network.@route[-1].target="${DEVICE_IP}"
uci set network.@route[-1].netmask='255.255.255.255'
uci set network.@route[-1].interface="${ON_IF}"
uci add firewall nat
uci set firewall.@nat[-1].src='on_mesh'
uci set firewall.@nat[-1].target='SNAT'
uci set firewall.@nat[-1].dest_ip="${DEVICE_IP}"
uci set firewall.@nat[-1].snat_ip="${ON_IF_IP}"
uci set firewall.@nat[-1].name="${DEVICE_NAME}"
uci set firewall.@nat[-1].proto='all'

# bridge-z10-db0hro - IP: 192.168.5.54/16 ; GW: 192.168.11.245 ; VLAN: 11
DEVICE_NAME="bridge-z10-db0hro"
DEVICE_IP="192.168.5.54"
ON_IF="on_eth_1"
ON_IF_IP="192.168.11.245"
uci add olsrd Hna4
uci set olsrd.@Hna4[-1].netmask='255.255.255.255'
uci set olsrd.@Hna4[-1].netaddr="${DEVICE_IP}"
uci add network route
uci set network.@route[-1].target="${DEVICE_IP}"
uci set network.@route[-1].netmask='255.255.255.255'
uci set network.@route[-1].interface="${ON_IF}"
uci add firewall nat
uci set firewall.@nat[-1].src='on_mesh'
uci set firewall.@nat[-1].target='SNAT'
uci set firewall.@nat[-1].dest_ip="${DEVICE_IP}"
uci set firewall.@nat[-1].snat_ip="${ON_IF_IP}"
uci set firewall.@nat[-1].name="${DEVICE_NAME}"
uci set firewall.@nat[-1].proto='all'

# EdgeSwitch - 192.168.5.57/16 ; GW: 192.168.5.56 ; VLAN: 1
DEVICE_NAME="switch-z10-4"
DEVICE_IP="192.168.5.57"
ON_IF="on_eth_0"
ON_IF_IP="192.168.1.245"
uci add olsrd Hna4
uci set olsrd.@Hna4[-1].netmask='255.255.255.255'
uci set olsrd.@Hna4[-1].netaddr="${DEVICE_IP}"
uci add network route
uci set network.@route[-1].target="${DEVICE_IP}"
uci set network.@route[-1].netmask='255.255.255.255'
uci set network.@route[-1].interface="${ON_IF}"
uci add firewall nat
uci set firewall.@nat[-1].src='on_mesh'
uci set firewall.@nat[-1].target='SNAT'
uci set firewall.@nat[-1].dest_ip="${DEVICE_IP}"
uci set firewall.@nat[-1].snat_ip="${ON_IF_IP}"
uci set firewall.@nat[-1].name="${DEVICE_NAME}"
uci set firewall.@nat[-1].proto='all'

uci commit

# enable NTP server so Mikrotik Router has time source
uci set system.ntp.enable_server='1'
uci commit
/etc/init.d/sysntpd restart

#todo ssh cert



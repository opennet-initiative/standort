#we assume Opennet Firmware 0.5.6-stable is installed on ER-X router

#
# In the following you find the configuration of this device.
#

# connect to eth1 for administration (dhcp)

# change root password
passwd

# we do not need OpenVPN
opkg remove on-openvpn

# install monitoring (we need Internet connection for this step, therefore connect port eth0 to Internet)
opkg-oni install on-monitoring

# as of today (May 2021) olsrd2 is always deactivated by default. We enable it.
on-function enable_on_module on-olsr2

# set IP
on-function set_opennet_id 3.90

# ER-X has the following ports:
# eth0 = WAN
# eth1 = LAN1
# eth2 = LAN2
# eth3 = LAN3
# eth4 = LAN4

#concept for switching + routing
# VLAN IDs
#  1: LAN    - LAN1+LAN2+LAN3 - br-lan (172.16.0.1/24)   - use for management access
#  2: MESH_1 - WAN            - on_eth_0 (192.168.5.52)  - bridge_bauamt_z10  (192.168.5.53)
#  3: MESH_2 - LAN4           - on_eth_1 (192.168.15.52) - bridge_warnemuende (192.168.5.55)

#configure switching
# VLAN 1 (preconfigured)
#       network.@switch_vlan[0]=switch_vlan
#       network.@switch_vlan[0].device='switch0'
#       network.@switch_vlan[0].vlan='1'
#       network.@switch_vlan[0].vid='1'
uci set network.@switch_vlan[0].ports='1 2 3 6t'  # only change associated ports
# VLAN 2 (preconfigured)
#       network.@switch_vlan[1]=switch_vlan
#       network.@switch_vlan[1].device='switch0'
#       network.@switch_vlan[1].vlan='2'
uci set network.@switch_vlan[1].ports='0 6t'  # only change associated ports
#       network.@switch_vlan[1].vid='2'
# VLAN 3 (new)
uci add network switch_vlan
uci set network.@switch_vlan[2]=switch_vlan
uci set network.@switch_vlan[2].device='switch0'
uci set network.@switch_vlan[2].vlan='3'
uci set network.@switch_vlan[2].ports='4 6t'
uci set network.@switch_vlan[2].vid='3'

#fix zones-interface association
#reset zone wan
uci set network.wan.ifname='none'
#reset zone wan6
uci set network.wan6.ifname='none'
uci set network.wan6.reqaddress='try'
uci set network.wan6.reqprefix='auto'
#assign on_eth_0 to VLAN 2
uci set network.on_eth_0.ifname='eth0.2'
#assign on_eth_0 to VLAN 3
uci set network.on_eth_1.ifname='eth0.3'

#
# make connected non-OLSR devices available in mesh network
#

# HNA
uci add olsrd Hna4
uci set olsrd.@Hna4[0].netmask='255.255.255.255'
uci set olsrd.@Hna4[0].netaddr='192.168.5.53'
uci add olsrd Hna4
uci set olsrd.@Hna4[1].netmask='255.255.255.255'
uci set olsrd.@Hna4[1].netaddr='192.168.5.54'
# static routes
uci add network route
uci set network.@route[0].target='192.168.5.53'
uci set network.@route[0].netmask='255.255.255.255'
uci set network.@route[0].interface='on_eth_0'
uci add network route
uci set network.@route[1].target='192.168.5.54'
uci set network.@route[1].netmask='255.255.255.255'
uci set network.@route[1].interface='on_eth_1'
# SNAT
uci add firewall nat
uci set firewall.@nat[0].src='on_mesh'
uci set firewall.@nat[0].target='SNAT'
uci set firewall.@nat[0].dest_ip='192.168.5.53'
uci set firewall.@nat[0].snat_ip='192.168.3.90'  # via on_eth_0
uci set firewall.@nat[0].name='bridge-bauamt'  # todo change to 'bridge-z10'
uci set firewall.@nat[0].proto='all'
uci add firewall nat
uci set firewall.@nat[1].src='on_mesh'
uci set firewall.@nat[1].name='bridge-warnemuende'
uci set firewall.@nat[1].target='SNAT'
uci set firewall.@nat[1].dest_ip='192.168.5.54'
uci set firewall.@nat[1].snat_ip='192.168.13.90'  # via on_eth_1
uci set firewall.@nat[1].proto='all'


#todo ssh cert

uci commit

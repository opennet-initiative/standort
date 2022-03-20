#we assume Opennet Firmware 0.5.6-stable is installed on ER-X router

#
# In the following you find the configuration of this device.
#


# change root password
passwd

# set IP
on-function set_opennet_id 2.191

# we do not need OpenVPN
opkg remove on-openvpn

# as of today (May 2021) olsrd2 is always deactivated by default. We enable it.
on-function enable_on_module on-olsr2

#config wifi-device 'radio0'
#	option type 'mac80211'
#	option hwmode '11a'
uci set wireless.radio0.htmode='HT20'
uci set wireless.radio0.country='DE'
uci set wireless.radio0.distance='2800'
uci set wireless.radio0.channel='104'
uci set wireless.radio0.chanlist='44 100-120 136-140'

#config wifi-iface 'default_radio0'
#	       option device 'radio0'
uci set  wireless.default_radio0.mode='ap'
#	       option encryption 'none'
#        option network 'on_wifi_0'
#	       option ifname 'wlan0'
#	       option isolate '1'
uci set  wireless.default_radio0.ssid='Z10-Zuckerfabrik.on-i.de'


#
# change eth0 interface from br-lan to on_eth_0
# (Note: when commiting these commands your connection gets lost! You need to connect to mesh IP afterwards.)
#
uci set network.lan.ifname='none'
uci set network.on_eth_0.ifname='eth0'



# install monitoring (we need Internet connection for this step, therefore connect port eth0 to Internet)
opkg-oni install on-monitoring

#todo ssh cert

uci commit

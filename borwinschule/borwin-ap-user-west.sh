# we assume 0.5.7-unstable-2964 is installed

#
# In the following you find the configuration of this device.
#

# change root password
passwd

# set IP
on-function set_opennet_id 1.159

# configure wifi (for some reason these was no good default setting via oni firmware)
uci set wireless.radio0.band='5g'
uci set wireless.radio0.country='DE'
uci set wireless.radio0.htmode='VHT20'
uci set wireless.radio0.channel='auto'
uci set wireless.radio0.chanlist='44 100-120 136-140'
uci set wireless.default_radio0.ssid='borwin-user-west.on-i.de'
uci set wireless.default_radio0.mode='ap'
uci commit

# now connect your client (with mesh ip and olsr) via wifi (SSID: see above)

# configure eth port for mesh
uci delete network.lan.device
uci set network.on_eth_0.device='eth0'
uci delete network.on_eth_0.ifname   # workaround: converting all 'ifname' to 'device' seems to not work when we manually have added a 'device' but the config is still in old (pre 21.02) format
uci commit

# now physically connect port eth0 with mesh
# after some time you should be able to ping 192.168.0.245

# install monitoring tools
opkg-oni install on-monitoring on-goodies tcpdump-mini
#if you get an error while downloading (due to cert problem) then wait 2min and try again. Maybe ntp needs to be synced.

# as of today (May 2021) olsrd2 is always deactivated by default. We enable it.
on-function enable_on_module on-olsr2

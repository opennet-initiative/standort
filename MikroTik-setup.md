# Configuration of MikroTik devices

## Typical Configurations

### Mikrotik mANTBox 15s

There are at least two possibilities to access a new mANTBox:
* Use [WinBox Tool](https://wiki.mikrotik.com/wiki/Manual:Winbox). This tool scan for devices in the network and you can access the configuration interface.
* DHCP Server: When booting the mANTBox an IP address via DHCP is requested. You need to have a DHCP server in the network and find the IP of the device. Maybe you want to start a local dhcp server via `sudo dnsmasq -i MY_ETH_INTERFACE_NAME --dhcp-range=192.168.1.100,192.168.1.200 -d -p0 -K --log-dhcp --bootp-dynamic`

We assume here that we want to configure the device as Access Point. Base configuration can be done via:

* Quick Set: `PTP Bridged AP`
* Network Name: ...enter SSID here...
* Frequency: set to `auto`
* Band: select 5GHz-A/N/AC
* Channel With: 20MHz
* Country: germany
* Address Acquisition: Static
* IP Address: ...
* Netmask: 255.255.0.0 (/16)
* Gateway: ...
* DNS: ...
* Router Identity: APx.Y
* Password: ...

If you now press *OK* or *Apply* the wifi interface will not come up immediately because it will first scan some minutes (up to 10min) for radar (DFS). You can see the current status in

* WebFig -> Interfaces -> wlan1 -> now check status (running ap vs. detecting radar) in below bar
* via CLI: ` /interface wireless monitor wlan1`

In addition we need to change the following:
* change from mode `bridge` to `ap bridge`. If we miss this setting only one peer can connect via WiFi.
  * WebFig -> Interfaces -> wlan1 -> Wireless -> Mode: `ap bridge`
* set `outdoor` installation so only outdoor channels will be used:
  * WebFig -> Interfaces -> wlan1 -> Wireless -> Installation: outdoor
* configure NTP client
  * WebFig -> System -> SNTP Client













### Mikrotik LHG 5 ac

* You can reset the configuration by pressing and hold *Reset* Button and powering on the device at the same time. Hold the button until the second LED begins to blink constantly. Then release the *Reset* Button. After 2min you should be able to connect to the device via 192.168.88.1/24.

* disable service we do not need
  * WebFig -> IP -> DHCP Server : delete the first line.
  * WebFig -> IP -> Firewall -> NAT : click on the first rule and uncheck *Enabled*. Press *OK*.
  * WebFig -> IP -> Services : disable *telnet*
* configure IP
  * WebFig -> IP -> Addresses -> select first entry and insert the new IP
  * now you need to connect (via webbrowser) to the new IP
* configure WiFi
  * for configuring the device as "PTP Bridge AP" do the following:
    * WebFig -> Wireless -> click on "wlan1" line and configure the following settings:
      * Mode: "bridge"
      * Channel Width: 20MHz
      * Frequency: ...
      * SSID: ...
      * Country: germany
      * now press "Apply" button and check the message directly under the buttons. If you see any message like "Radar detected" then WiFi will not start.
  * for configuring the device as "PTP Bridge CPE" to the following:
    * simplest way to connect to existing WiFi network is doing a scan and select the network
      * WebFig -> Wireless -> WiFi Interfaces -> select button *scanner* and press *Start*. Now you should see the wifi network of the other device. Select this entry and press *Connect*. After some second you should see the Tx/Tx counters increasing.

* Firewall: allow anything.
  * WebFig -> IP -> Firewall -> Add New
    * Chain: forward -> OK
    * Chain: input -> OK
    * Chain: output -> OK
  * Delete all rules except our new rules. Note: First rule cannot be deleted because it is a builtin rule.
* enable Bridge
  * WebFig -> Bridge -> Bridge -> Add New. Stay with default setting and press *OK*.
  * WebFig -> Bridge -> Ports -> Add New. Select as Interface *wlan1* and press *OK*.
  * WebFig -> Bridge -> Ports -> Add New. Select as Interface *ether1* and press *OK*.

* Hostname
  * WebFig -> System -> Identity : insert the hostname here
* Password
  * WebFig -> System -> Password

* maybe configure in future
  * DNS / NTP / Syslog ?
  * HTTPS webinterface is disabled by default. To activate it you need to generate a certificate as described in https://www.medo64.com/2016/11/enabling-https-on-mikrotik/. Set correct time before creating certificates else they are already expired.

* saving config backup
  * log in via SSH and then execute
    * *export compact file config-backup.txt*
    * you can list all files on the router via *file print*
    * now you need to download the file via ftp or sftp, e.g. by executing the following command on your computer: *sftp admin@IP_OF_ACCESSPOINT:config.txt*
* importing config backups
  * copy config backup file to access point via ftp or sftp
  * log in via SSH and then execute
    * /system reset-configuration run-after-reset=config.txt

Note: LHG device is intended for outdoor bridge. Therefore you have the following restrictions:
* no indoor channel can be configured
* normal AccessPoint mode is not possible (would need RouterOS license level 4)


## Connect to device (WinBox vs. static IP)

Connecting to a Mikrotik device with factory default configuration is a little bit of pain compared to Ubnt devices. You can choose between two methods:

* WinBox tool (easy to use but extra program to install)
* dhcp server needed

Mikrotik has a tool called WinBox which is able to connect via Layer2 to Mikrotik devices. The advantage is that no IP addresses are needed. Sadly this tool is a Windows tool. You can use it in Linux and MacOS using Wine.

* Windows: https://mikrotik.com/download
* MacOS: https://help.mikrotik.com/docs/display/ROS/Winbox#Winbox-RunWinboxonmacOS
* Linux: https://help.mikrotik.com/docs/display/ROS/Winbox#Winbox-RunWinboxonLinux

If you do *not want to use WinBox* then you need to know how Mikrotik devices fetch IP in factory default configuration. By default the devices try to get an IP via DHCP. Therefore the network must provide a DHCP server and you need to find out which IP address the device was aquiring. If you know the IP you can connect to the web interface *without* SSL, therefore using http://IP_OF_DEVICE.

## Firmware Update (via cable connecting with WinBox)

* Connect a cable from your device (use WAN port if available) to your Internet router.
* Boot the device with factory configuration.
* Make sure you are (with your laptop) in the same network.
* Open WinBox
* Select device in neighbour list
* Activate DHCP client on Mikrotik device:
  * WebFig -> IP -> DHCP client -> add `ether1`
  * now Internet connection should be available. You can check with `ping 8.8.8.8` in console.
* check whether new firmware available: `/system package update check-for-updates`
* if available then download: `/system package update download`
* reboot to make upgrade available: `/system reboot`
* (wait for 3min) after reboot
* now we should see the new firmware version as "upgrade firmware": `/system routerboard print`
* do upgrade: `/system routerboard upgrade`
* final reboot: `/system reboot`
* delete old config (dhcp client config from above) via: `/system reset-configuration`

## Firmware Update (via Wi-Fi connecting with WinBox)

* Connect device as Wi-Fi client to your home network
* ...todo...

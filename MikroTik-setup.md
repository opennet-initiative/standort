= Configuration of MikroTik devices

== Firmware Update

After boot AP has IP 192.168.88.1 with DHCP server active.

Now we need to update the firmware.

Note: LHG device is intended for outdoor bridge. Therefore you have the following restrictions:
* no indoor channel can be configured
* normal AccessPoint mode is not possible (would need RouterOS license level 4)


=== Connect LHG to a network with internet connection for firmware update

We configure the LAN interface with static IP in our home network.

* WebFig -> IP -> DNS -> Server : insert IP of your DNS server
* WebFig -> IP -> Routes -> Routes -> Add New
  * Dst. Address: 0.0.0.0/0
  * Gateway: IP_OF_YOUR_GATEWAY
  * OK
* WebFig -> IP -> Addresses -> select *ether1*
  * Address: FREE_IP_IN_YOUR_HOME_NETWORK
  * OK

Now you lose connection to the device because it has a new IP.
Connect the LHD via cable to you home network.
You should now be able to ping FREE_IP_IN_YOUR_HOME_NETWORK.

=== Update firmware

* ssh admin@FREE_IP_IN_YOUR_HOME_NETWORK
* check whether new firmware available: /system package update check-for-updates
* if available then download: /system package update download
* reboot to make upgrade available: /system reboot
* (wait for 3min) after reboot log in via SSH again
* now we should see the new firmware version as "upgrade firmware": /system routerboard print
* do upgrade: /system routerboard upgrade
* final reboot: /system reboot
* now it is a good moment to revert all settings to factory reset via: /system reset-configuration


== RouterOS - LHG specific

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

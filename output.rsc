# model = RB4011iGS+

/interface bridge
add name=bridge

/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN

/ip dhcp-server option
add code=43 name=config value=\
    0x0220687474703a2f2f3139322e3136382e312e3130303a383030302f636f6e666967
add code=66 name=option66 value=\
    0x687474703a2f2f3139322e3136382e312e3130303a383030302f636f6e666967
/ip dhcp-server option sets
add name=options options=config,option66
/ip pool
add comment=mngt name=dhcp-5-mngt ranges=10.2.11.90-10.2.11.99
add comment=core name=dhcp-10-core ranges=10.3.11.90-10.3.11.99
add comment=sip-phones name=dhcp-20-voip ranges=192.168.21.10-192.168.22.254
/ip dhcp-server
add address-pool=dhcp-20-voip comment=sip-phones dhcp-option-set=options \
    interface=ether2 lease-time=3d name=voip-20
add address-pool=dhcp-5-mngt comment=mngt interface=ether5 lease-time=1h \
    name=mngt-5
add address-pool=dhcp-10-core interface=ether1 lease-time=1h name=core

/port
set 0 name=serial0
set 1 name=serial1

/interface l2tp-client
add connect-to=10.0.11.1 disabled=no name=l2tp-11\
   profile=default user=user11 password=ChangePassword

/routing ospf instance
add disabled=no name=ospf-instance-1 out-filter-chain=ospf-out \
    out-filter-select="" redistribute=connected,static router-id=10.0.11.2
/routing ospf area
add disabled=no instance=ospf-instance-1 name=ospf-area-1

/interface bridge port
add bridge=bridge comment=defconf disabled=yes interface=ether1
add bridge=bridge comment=defconf disabled=yes interface=ether2
add bridge=bridge comment=defconf disabled=yes interface=ether5
add bridge=bridge comment=defconf disabled=yes interface=ether10
add bridge=bridge comment=defconf disabled=yes interface=sfp-sfpplus1
/interface list member
add interface=ether1 list=LAN
add interface=ether2 list=LAN
add interface=ether5 list=LAN
add interface=ether10 list=WAN
add interface=l2tp-11 list=WAN

/ip address
add address=10.3.11.1/24 comment=core interface=ether1 network=10.3.11.0
add address=192.168.21.1/23 comment=voip interface=ether2 network=192.168.21.0
add address=10.2.11.1/24 comment=mngt interface=ether5 network=10.2.11.0
add address=10.0.11.2/30 comment=net interface=ether10 network=10.0.11.0

/ip dhcp-server network
add address=10.2.11.0/24 comment=mngt dns-server=10.2.11.1 gateway=10.2.11.1 \
    netmask=24 ntp-server=10.2.11.1
add address=10.3.11.0/24 comment=core dns-server=10.3.11.1 gateway=10.3.11.1 \
    netmask=24 ntp-server=10.3.11.1
add address=192.168.21.0/23 comment=sip-phones dhcp-option=*3 dns-server=\
    192.168.21.1 gateway=192.168.21.1 netmask=23 ntp-server=192.168.21.1

/ip dns
set allow-remote-requests=yes
/ip dns static
add address=10.2.11.1 name=r11 type=A
add address=10.2.0.2 name=r1 type=A
add address=10.2.0.3 name=r2 type=A

/ip firewall address-list
add address=10.3.0.11 list=mngt
add address=192.168.0.10 list=mngt
/ip firewall filter
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related hw-offload=yes
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment=OSPF protocol=ospf
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="All from LAN" in-interface-list=LAN
add action=accept chain=input comment="Remote mngt" dst-address=10.2.11.1 \
    dst-port=22,80,443,8291 in-interface-list=WAN protocol=tcp src-address=\
    10.2.0.0/24
add action=drop chain=input comment=\
    "Drop all other unsolicited WAN to Router" in-interface-list=WAN
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=reject chain=forward comment="Reject mngt ports to remote" \
    dst-port=22,80,443,8291 in-interface=ether2 protocol=tcp reject-with=\
    icmp-network-unreachable
add action=accept chain=forward comment=LAN-to-LAN in-interface-list=LAN \
    out-interface-list=LAN
add action=accept chain=forward comment=LAN-2-WAN in-interface-list=LAN \
    out-interface-list=WAN
add action=accept chain=forward comment=WAN-2-LAN in-interface-list=WAN \
    out-interface-list=LAN
add action=drop chain=forward comment="Drop everything else"
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" disabled=yes \
    ipsec-policy=out,none out-interface-list=WAN
/ip firewall service-port
set h323 disabled=yes
set sip disabled=yes

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh address=10.2.0.0/24,10.2.11.0/24
set www-ssl address=10.2.0.0/24,10.2.11.0/24 disabled=no
set winbox address=10.2.0.0/24,10.2.11.0/24

/routing filter rule
add chain=ospf-out disabled=no rule=\
    "if (dst == 192.168.88.0/24) {reject}\r\
    \n"
add chain=ospf-out disabled=no rule=accept
add chain=OSPF-IN-FILTER disabled=yes rule=\
    "if (dst == 10.3.0.0/24) { reject } else { accept }"
/routing ospf interface-template
add area=ospf-area-1 cost=10 disabled=yes interfaces=ether10
add area=ospf-area-1 disabled=no interfaces=ether1 passive type=ptp
add area=ospf-area-1 disabled=no interfaces=ether2 passive type=ptp
add area=ospf-area-1 disabled=no interfaces=ether5 passive type=ptp
add area=ospf-area-1 disabled=no interfaces=l2tp-11 type=ptp

/system clock
set time-zone-autodetect=no time-zone-name=Asia/Yerevan
/system identity
set name=r11
/system logging
add topics=ospf
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp server
set enabled=yes
/system ntp client servers
add address=10.0.1.1
add address=10.0.1.2
/system routerboard settings
set enter-setup-on=delete-key

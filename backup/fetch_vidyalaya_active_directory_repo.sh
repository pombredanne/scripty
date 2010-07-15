smbmount //192.168.2.253/D\$ /media/lan_server -o user=SERVERMCA/bca3 password=

hg fetch /media/lan_server/Softwares/vidyalaya_active_directory -R ~/scripts/vidyalaya_active_directory

smbumount /media/lan_server

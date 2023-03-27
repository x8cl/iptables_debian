#!/bin/sh
folder="/home/firewall"
###Descargar el archivo desde iblocklist
echo "Descargando el archivo desde iblocklist..."
##Gratis (P2P/gz) Chile
curl -L 'http://list.iblocklist.com/?list=cl&fileformat=p2p&archiveformat=gz' | gunzip | awk -F ':' '{print $2}' > $folder/cl.zone
##Pagado (CIDR/gz)
#curl -L -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" "http://list.iblocklist.com/?list=jdinualmqtpcrnptnqbq&fileformat=cidr&archiveformat=gz&username=netvoiss&pin=913915" | gunzip > $folder/iblocklist.zone

###Descargar el archivo desde google docs otras.zone
#echo "Descargando el archivo otras.zone..."
#curl -L "https://docs.google.com/feeds/download/documents/export/Export?id=18_Su7xlUx6IBkHx_pYFBNfvRLj9RJqYiil_iHdhku0g&exportFormat=txt" > $folder/otras.zone

###IPSET by MAB
echo "-----IPSET by MAB-----"
echo "Creando/Limpiando ipset \"permitidas\"..."
ipset create permitidas hash:net -exist
ipset flush permitidas
echo "Agregando IPs permitidas al ipset \"permitidas\"..."
for IP in $(cat $folder/*.zone | grep -v \# | grep -v '^[[:space:]]*$' | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed $'s/\r//') ; do ipset -A permitidas $IP -exist ; done

###IPTables By MAB
echo "-----IPTABLES by MAB-----"
##Limpiando Reglas anteriores
echo "Limpiando Reglas de Firewall ipv4..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t filter -F
iptables -t filter -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

##Creando nuevas POLICY con DROP
echo "Aplicando POLICY INPUT y FORWARD DROP ipv4..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

##Creando nuevas reglas del firewall
echo "Aplicando Reglas de Firewall ipv4..."
echo "Aceptamos todo en loopback..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

##Aceptamos todo en LAN
#echo "Aceptamos todo desde/hacia LAN..."
#iptables -A INPUT -i ens265 -j ACCEPT
#iptables -A OUTPUT -o ens256 -j ACCEPT

##PING
echo "Aceptamos ping reply..."
iptables -t filter -A INPUT -p icmp --icmp-type echo-reply -m state --state ESTABLISHED,RELATED -j ACCEPT
echo "Aceptamos PING solo desde IPs del ipset \"permitidas\"..."
iptables -t filter -A INPUT -m set --match-set permitidas src -p icmp --icmp-type echo-request -j ACCEPT

##ESTABLISHED,RELATED
echo "Aceptamos respuesta a las conexiones ya establecidas..."
iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

##Servicios filtrados por ipset
echo "Abrimos puertos de los servicios solo desde IPs del ipset \"permitidas\"..."
#Acepto solo IPs del ipset "permitidas" para SSH TCP 10041
iptables -t filter -A INPUT -m set --match-set permitidas src -m tcp -p tcp --dport 10041 -j ACCEPT
#Acepto solo IPs del ipset "permitidas" para SIP en UDP 5060
#iptables -t filter -A INPUT -m set --match-set permitidas src -m udp -p udp --dport 5060 -j ACCEPT
#Acepto paquetes RTP de cualquir parte en UDP 10000:20000
#iptables -t filter -A INPUT -m udp -p udp --dport 10000:20000 -j ACCEPT

##Servicios abiertos a todas partes...
#echo "Aceptamos PING de todas partes..."
#iptables -t filter -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

#echo "Abrimos puertos de los servicios para todas partes..."
#Acepto conexiones para SSH TCP 10041 desde todas partes
#iptables -t filter -A INPUT -m tcp -p tcp --dport 10041 -j ACCEPT


##IPv6
echo "Limpiando Reglas de Firewall ipv6..."
ip6tables -F
ip6tables -X
ip6tables -t nat -F
ip6tables -t nat -X
ip6tables -t mangle -F
ip6tables -t mangle -X
ip6tables -t filter -F
ip6tables -t filter -X
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT

#echo "Aplicando POLICY INPUT y FORWARD DROP ipv6..."
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

##Creando nuevas reglas del firewall
echo "Aplicando Reglas de Firewall ipv6..."
##Aceptamos todo en loopback
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

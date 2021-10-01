# iptables-firewall
Un simple script en bash que permite mediante curl, ipset e iptables utilizar listas de IPs para bloquear TODO en un principio y luego abrir los puertos, por servicio y por listas de IPs (IP individuales como 10.10.10.123, grupos como 10.10.10.123-10.10.10.234 o segmentos como 10.10.10.0/24 en archivos .zone) ademas de descargar listas de paises P2P/gz o CIDR/gz desde iblocklist, es solo editar ;)

Uso:
1. descargar el archivo firewall.sh (Ej: /home/firewall/firewall.sh)
2. editar archivo /home/firewall/firewall.sh y verificar que al menos el puerto SSH esté permitido (IMPORTANTE!!!)
3. chmod +x /home/firewall/firewall-st*
4. descargar MAB-firewall.service en /usr/lib/systemd/system/MAB-firewall.service y editarlo si es necesario (comentado lo necesario)
5. systemctl enable MAB-firewall
6. systemctl start MAB-firewall
7. crontab -e
8. agragar:
*/30 * * * * sh /home/firewall/firewall-start.sh >/dev/null 2>&1

firewall-stop.sh borrará todas las reglas y dejará iptables limpio. Puede ser utilizado en crond por si nos mandamos un "cagazo" en iptables y dejará todo limpio dentro de 0/5 (5 minutos)
Es el "salvavidas" si estamos negando todas las conexiones (INPUT DROP) 

*/5 0 * * * sh /home/firewall/firewall-stop.sh >/dev/null 2>&1
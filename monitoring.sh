#!/bin/bash
arc=$(uname -a)
#chope les infos du kernel
#pcpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
pcpu=$(grep "physical id" /proc/cpuinfo | wc -l)
#recupere la listes des processeurs physique et les compte 
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)
#recupere la listes des processeurs virtuels et les compte 
fram=$(free -m | awk '$1 == "Mem:" {print $2}')
#recupere les infos de memoire vive avec awk on chope la valeur de la pemiere ligne et du deuxieme parametre (le total disponible) la conversion en pourcentage se fait apres
uram=$(free -m | awk '$1 == "Mem:" {print $3}')
#recupere les infos de memoire vive avec awk on chope la valeur de la pemiere ligne et du troisieme parametre (le total disponible) la conversion en pourcentage se fait apres
pram=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
#calcul du pourcentage de memoire libre
fdisk=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
#comme pour en haut mais avec le stockage
udisk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
#pareil
pdisk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {printf("%d"), ut/ft*100}')
#pareil
cpul=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
#recuperation des donnees de la charge du cpy (cpu load)
lb=$(who -b | awk '$1 == "system" {print $3 " " $4}')
#who -b donne le dernier boot du systeme
lvmt=$(lsblk | grep "lvm" | wc -l)
#lsblk monitore les partitions du systeme, ca renvoie 0 si lvm est desactive et 1 si c'est active 
lvmu=$(if [ $lvmt -eq 0 ]; then echo no; else echo yes; fi)
#You need to install net tools for the next step [$ sudo apt install net-tools]
ctcp=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')
#cat le ficher 'sockstat' et le fichier 'sockstat6' et recupere le nombre de connexion TCP active
ulog=$(users | wc -w)
#recupere le nombre de users actifs et les compte
ip=$(hostname -I)
#recupere l'adresse IP
mac=$(ip link show | awk '$1 == "link/ether" {print $2}')
#recupere l'adresse mac
cmds=$(journalctl _COMM=sudo | grep COMMAND | wc -l)
#recupere le nombre de commandes sudo et les compte
wall "	#Architecture: $arc
	#CPU physical: $pcpu
	#vCPU: $vcpu
	#Memory Usage: $uram/${fram}MB ($pram%)
	#Disk Usage: $udisk/${fdisk}Gb ($pdisk%)
	#CPU load: $cpul
	#Last boot: $lb
	#LVM use: $lvmu
	#Connexions TCP: $ctcp ESTABLISHED
	#User log: $ulog
	#Network: IP $ip ($mac)
	#Sudo: $cmds cmd"

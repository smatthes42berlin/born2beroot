# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    monitoring_reboot.sh                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: smatthes <smatthes@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/07/29 08:01:03 by smatthes          #+#    #+#              #
#    Updated: 2023/08/25 13:01:53 by smatthes         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

while true

do

# username=$(who | awk '{print $1}')
# tty=$(who | awk '{print $NF}')
# hostname=$(hostname)
# date=$(date "+%a %b %d %H:%M:%S %Y")

architecture=$(uname -a)

cpu=$(lscpu | awk '/^CPU\(s\):/ {print $2}')

# vcpu=$(nproc)
threadspercore=$(lscpu | awk -F ':' '/^Thread\(s\) per core:/ {print $2}')
corespersocket=$(lscpu | awk -F ':' '/^Core\(s\) per socket:/ {print $2}')
sockets=$(lscpu | awk '/^Socket\(s\):/ {print $2}')
vcpu=$(awk -v threadspercore="$threadspercore" -v corespersocket="$corespersocket" -v sockets="$sockets" 'BEGIN {printf("%.0f", threadspercore * corespersocket * sockets)}')

totalmemmb=$(free -k | awk '/Mem:/ {printf("%.0f"), $2/1024}')
usedmemmb=$(free -k | awk '/Mem:/ {printf("%.0f"), $3/1024}')
mempercent=$(awk "BEGIN { printf \"%.2f\", 100 * $usedmemmb / $totalmemmb }")

diskspaceusedmb=$(df --total -BM | awk 'END {print substr($3, 1, length($3)-1)}')
diskspacetotalmb=$(df --total -BM | awk 'END {print substr($2, 1, length($3)-1)}')
diskspacetotalgb=$(df --total -BG | awk 'END {print substr($2, 1, length($3)-1)}')
disksapcepercent=$(awk "BEGIN { printf \"%.0f\", 100 * $diskspaceusedmb / $diskspacetotalmb }")

cpuusage=$(top -n1 | awk 'BEGIN {sum=0} NR>7 {sum=sum+$10} END{print sum}')

lastboot=$(who -b | awk '{print $3" "$4}')

lvmvolumes=$(lsblk | awk '/lvm/ {print $0}' | wc -l)
lvmuse=$(if [ $lvmvolumes -eq 0 ]; then echo no; else echo yes; fi)

numbertcpestab=$(ss | awk '/^tcp/ {print $0}' | awk '/ESTAB/ {print $0}' | wc -l)

numberofussers=$(users | wc -w)

ipaddr=$(hostname -I | awk '{print $1}')
macaddr=$(ip a | awk '/link\/ether/ {print $2; exit}')

# numcmdssudo=$(awk '{print $0}' /var/log/sudo/sudo.log | wc -l)
numcmdssudo=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall	 "            #Architecture: $architecture
            #CPU physical : $cpu
            #vCPU : $vcpu
            #Memory Usage : ${usedmemmb}/${totalmemmb}Mb (${mempercent}%)
            #Disk Usage : ${diskspaceusedmb}/${diskspacetotalgb}Gb (${disksapcepercent}%)
            #CPU load : ${cpuusage}%
            #Last boot : $lastboot
            #LVM use : $lvmuse
            #Connections TCP : $numbertcpestab ESTABLISHED
            #User log : $numberofussers
            #Network : IP $ipaddr ($macaddr)
            #Sudo : $numcmdssudo cmd
"
sleep 600
done

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    sys_info.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: smatthes <smatthes@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/07/29 08:01:03 by smatthes          #+#    #+#              #
#    Updated: 2023/08/02 15:54:42 by smatthes         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

username=$(who | awk '{print $1}')
tty=$(who | awk '{print $NF}')
hostname=$(hostname)
date=$(date "+%a %b %d %H:%M:%S %Y")

architecture=$(uname -a)

cpu=$(lscpu | awk '/^CPU\(s\):/ {print $2}')

vcpu=$(nproc)

totalmem=$(free | awk '/Mem:/ {print $2}')
totalmemmb=$(echo "scale=1; $totalmem / 1000" | bc)
usedmem=$(free | awk '/Mem:/ {print $3}')
usedmemmb=$(echo "scale=1; $usedmem / 1000" | bc)
mempercent=$(echo "scale=2; $usedmem / $totalmem * 100" | bc)

diskspaceusedmb=$(df -BM | awk 'BEGIN{NR > 1; sum=0} {sum=sum+$3} END{print sum}')
diskspacetotalmb=$(df -BM | awk 'BEGIN{NR > 1; sum=0} {sum=sum+$2} END{print sum}')
diskspacetotalgb=$(df -BG | awk 'BEGIN{NR > 1; sum=0} {sum=sum+$2} END{print sum}')
diskspacepercent=$(echo "scale=0; $diskspaceusedmb * 100 / $diskspacetotalmb" | bc)

cpuusage=$(top -n1 | awk 'BEGIN {sum=0} NR>7 {sum=sum+$10} END{print sum}')

lastboot=$(who -b | awk '{print $3" "$4}')

lvmvolumes=$(lsblk | awk '/lvm/ {print $0}' | wc -l)
lvmuse=$(if [ $lvmvolumes -eq 0 ]; then echo no; else echo yes; fi)

# 2>/dev/null means all errors are justed thrown way/ignored
numbertcpestab=$(netstat -t 2>/dev/null | awk '/ESTABLISHED/ {print $0}' | wc -l)

numberofussers=$(who | wc -l)

ipaddr=$(hostname -I | awk '{print $1}')
macaddr=$(ip a | awk '/link\/ether/ {print $2; exit}')

numcmdssudo=$(awk '{print $0}' /var/log/auth.log | wc -l)

wall "  Broadcast message from $username@$hostname ${tty} ($date):
            #Architecture: $architecture
            #CPU physical : $cpu
            #vCPU : $vcpu
            #Memory Usage : $usedmemmb/$totalmemmbMb ($mempercent%)
            #Disk Usage : $diskspaceusedmb/$diskspacetotalgb ($diskspacepercent%)
            #CPU load : $cpuusage%
            #Last boot : $lastboot
            #LVM use : $lvmuse
            #Connections TCP : $numbertcpestab ESTABLISHED
            #User log : $numberofussers
            #Network : IP $ipaddr ($macaddr)
            #Sudo : $numcmdssudo cmd
"

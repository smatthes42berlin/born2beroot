# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    sys_info.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: smatthes <smatthes@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/07/29 08:01:03 by smatthes          #+#    #+#              #
#    Updated: 2023/07/30 17:24:10 by smatthes         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

username=$(who | awk '{print $1}')
tty=$(who | awk '{print $NF}')
hostname=$(hostname)
date=$(date "+%a %b %d %H:%M:%S %Y")

echo -e "   "Broadcast message from $username@$hostname ${tty} \($date\):
echo

function echo_indented() {
    echo -e "\t\t#"$1
}

architecture=$(uname -a)
echo_indented "Architecture: $architecture"

cpu=$(lscpu | awk '/^CPU\(s\):/ {print $2}')
echo_indented "CPU physical : $cpu"

vcpu=$(nproc)
echo_indented "vCPU : $vcpu"

totalmem=$(free | awk '/Mem:/ {print $2}')
totalmemmb=$(echo "scale=1; $totalmem / 1000" | bc)
usedmem=$(free | awk '/Mem:/ {print $3}')
usedmemmb=$(echo "scale=1; $usedmem / 1000" | bc)
mempercent=$(echo "scale=2; $usedmem / $totalmem * 100" | bc)
echo_indented "Memory Usage : ${usedmemmb}/${totalmemmb}Mb (${mempercent}%)"

diskspaceusedmb=$(df -BM | awk  'BEGIN{NR > 1; sum=0} {sum=sum+$3} END{print sum}')
diskspacetotalmb=$(df -BM | awk  'BEGIN{NR > 1; sum=0} {sum=sum+$2} END{print sum}')
diskspacetotalgb=$(df -BG | awk  'BEGIN{NR > 1; sum=0} {sum=sum+$2} END{print sum}')
diskspacepercent=$(echo "scale=0; $diskspaceusedmb * 100 / $diskspacetotalmb" | bc)
echo_indented "Disk Usage : ${diskspaceusedmb}/${diskspacetotalgb}Gb (${diskspacepercent}%)"

cpuusage=$(top -n1 | awk 'BEGIN {sum=0} NR>7 {sum=sum+$10} END{print sum}')
echo_indented "CPU load : ${cpuusage}%"

lastboot=$(who -b | awk '{print $3" "$4}')
echo_indented "Last boot : ${lastboot}"

lvmvolumes=$(lsblk | awk '/lvm/ {print $0}' | wc -l)
lvmuse=$(if [ $lvmvolumes -eq 0 ]; then echo no; else echo yes; fi)
echo_indented "LVM use : ${lvmuse}"

# 2>/dev/null means all errors are justed thrown way/ignored
numbertcpestab=$(netstat -t 2>/dev/null | awk '/ESTABLISHED/ {print $0}' | wc -l)
echo_indented "Connections TCP : ${numbertcpestab} ESTABLISHED"

numberofussers=$(who | wc -l)
echo_indented "User log : ${numberofussers}"

ipaddr=$(hostname -I | awk '{print $1}')
macaddr=$(ip a | awk '/link\/ether/ {print $2; exit}')
echo_indented "Network : IP ${ipaddr} (${macaddr})"

numcmdssudo=$(awk '{print $0}' /var/log/auth.log | wc -l)
echo_indented "Sudo : ${numcmdssudo} cmd"

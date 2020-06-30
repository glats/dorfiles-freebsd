#!/bin/sh
hddroot(){
	hddroot="`df -h | awk 'NR==2{print $3, $5}'`"
	echo -e "Disk: $hddroot"
}

#mem(){
#$ sysctl hw.physmem
#$ sysctl hw | egrep 'hw.(phys|user|real)'
#	mem="$(free | awk '/Mem/ {printf "%d MiB / %d MiB : %d%\n", $3 / 1024.0, $2 / 1024.0,  $3/$2 *100}')"
#	echo -e "MEM : $mem"
#}

brightness(){
	brightness="`sysctl -n hw.acpi.video.lcd0.brightness`"
	echo -e "Brightness: $brightness %"
}

cpu() {
	cpu_use=`uptime`
	IFS=',' read -ra avg_cpu_use_arr <<< "$avg_cpu_use"
	avg_cpu_usae=""
	echo -e "CPU: $cpu%"
}

vol(){
	# todo save 
	vol="`mixer -s vol | awk '{ print $2 }'`"
	echo -e "Volume: $vol %"
}

dte() {
	dte="`date +"%A, %B %d ~ %l:%M:%S %p CLT"`"
	echo -e "$dte"
}

SLEEP_SEC=0.5
while :; do
	echo "`hddroot` || `vol` || `brightness` || `dte`" 
	sleep $SLEEP_SEC
done

#!/bin/sh

# Strict script
#set -e causes the shell to exit when an unguarded statement evaluates to a false value (i have to disable because of cap lock function)
set -u

hdd(){
	hdd="`df -h | awk 'NR==2{print $5}'`"
	echo -e "Disk: $hdd"
}

mem_rounded () {
    mem_size=$1
    chip_size=1
    chip_guess=`echo "$mem_size / 8 - 1" | bc`
    while [ $chip_guess != 0 ]
        do
                chip_guess=`echo "$chip_guess / 2" | bc`
                chip_size=`echo "$chip_size * 2" | bc`
    done
    mem_round=`echo "( $mem_size / $chip_size + 1 ) * $chip_size" | bc`
    echo $mem_round
}

mem() {
        mem_phys=`sysctl -n hw.physmem`
        set +e
        mem_hw=`mem_rounded $mem_phys`
        set -e
        sysctl_pagesize=`sysctl -n hw.pagesize`
        mem_inactive=`echo "\`sysctl -n vm.stats.vm.v_inactive_count\` \
	* $sysctl_pagesize" | bc`
        mem_cache=`echo "\`sysctl -n vm.stats.vm.v_cache_count\` \
	* $sysctl_pagesize" | bc`
        mem_free=`echo "\`sysctl -n vm.stats.vm.v_free_count\` \
	* $sysctl_pagesize" | bc`

        mem_total=$mem_hw
        mem_avail=`echo "$mem_inactive + $mem_cache + $mem_free" | bc`
        mem_used=`echo "$mem_total - $mem_avail" | bc`

        #printf "%7dMB [%3d%%]" `echo "$mem_used / ( 1024^2 )" | bc` `echo "$mem_used * 100 / $mem_total" | bc`
        #printf "%7dMB [%3d%%]" `echo "$mem_avail / ( 1024^2 )" | bc` `echo "$mem_avail * 100 / $mem_total" | bc`
	#printf "%7dMB [100%%]" `echo "$mem_total / ( 1024 * 1024 )" | bc`

	#printf "RAM: Used: %dMB - %d%% Free: %dMB - %d%% Total: %dMB" `echo "$mem_used / ( 1024^2 )" | bc` \
	#`echo "$mem_used * 100 / $mem_total" | bc` `echo "$mem_avail / ( 1024^2 )" | bc` `echo "$mem_avail * 100 / $mem_total" | bc` \
	#`echo "$mem_total / ( 1024 * 1024 )" | bc` | xargs
	printf "Memory: %d%%" `echo "$mem_used * 100 / $mem_total" | bc`
}

bri(){
	brightness="`sysctl -n hw.acpi.video.lcd0.brightness`"
	#echo -e "Brightness: $brightness%"
	printf "Brightness: %s%%" `echo "$brightness"`
}

cpu() {
	cpu="`top -b -n 1 | grep -i "cpu" | head -n 1 | awk '{print $2 + $4}'`  "
	printf "CPU: %s%%" `echo "$cpu"`
}

vol(){
	# todo save into a file
	vol="`mixer -s vol | awk '{ print $2 }'`"
	echo -e "Volume: $vol%"
}

dte() {
	dte="`date +"%A, %B %d - %l:%M:%S %p CLT"`"
	echo -e "$dte"
}

bat() {
	bat="`apm -l`"
	printf "Battery: %s%%" `echo "$bat + 2" | bc`
}

layout() {
	lay_result="`xset -q | grep -i "led mask" | grep -o "....1..."`"
	lay="`[ -z $lay_result ] && echo "latam" || echo "es"`"
	echo -e "Keyboard: $lay"
}

lock() {
	cap_result=`xset q | grep -q 'Caps Lock: *on'`
	cap="`[ $? == 0 ] && echo "yes" || echo "no"`"
	num_result=`xset q | grep -q 'Num Lock: *on'`
	num="`[ $? == 0 ] && echo "yes" || echo "no"`"
	echo -e "Cap: $cap - Num: $num" 
}

SLEEP_SEC=0.5
while :; do
	echo "`cpu` || `mem` || `hdd` || `vol` || `bri` || `bat` || `layout` || `lock` || `dte`"
	sleep $SLEEP_SEC
done

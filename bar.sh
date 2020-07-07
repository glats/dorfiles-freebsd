#!/bin/sh

# Strict script
#set -e causes the shell to exit when an unguarded statement evaluates to a false value (i have to disable because of cap lock function)
set -u
#set -x

hdd(){
	hdd="`df -h | awk 'NR==2{print $5}'`"
	echo -e " $hdd"
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
	printf " %d%%" `echo "$mem_used * 100 / $mem_total" | bc`
}

bri(){
	brightness="`sysctl -n hw.acpi.video.lcd0.brightness`"
	#echo -e "Brightness: $brightness%"
	printf " %s%%" `echo "$brightness"`
}

cpu() {
	cpu="`top -b -n 1 | grep -i "cpu" | head -n 1 | awk '{print $2 + $4 + $6}'`  "
	printf " %s%%" `echo "$cpu"`
}

vol(){
	# todo save into a file
	vol="`mixer -s vol | awk -F' ' '{split($2,a,":"); print (a[1]+a[2])/2}'`"
	if [ $vol -gt 70 ]; then
	    icon=""
	elif [ $vol -eq 0 ]; then
	    icon=""
	elif [ $vol -lt 30 ]; then
	    icon=""
	else
	    icon=""
	fi
	printf "$icon %s%%" `echo "$vol"`
}

dte() {
	dte=" `date +"%Y-%m-%d"`  `date +"%H:%M"`"
	echo -e "$dte"
}

bat() {
	#bat="`apm -l`"
	#printf " %s%%" `echo "$bat" | bc`
	capacity=97
	current=`apm -l`
	status=`apm -a`

	if [ $status -eq 1 ] && [ $current -eq $capacity ]; then
		printf " %s%%" `echo "$capacity" | bc`
	fi
	if [ $status -eq 0 ] && [ $current -ne $capacity ]; then
		if [ $current -eq 100 ]; then
		    icon=""
		elif [ $current -gt 75 ]; then
		    icon=""
		elif [ $current -gt 50 ]; then
		    icon=""
		elif [ $current -lt 25 ]; then
		    icon=""
		elif [ $current -lt 5 ]; then
		    icon=""
		else
		    icon=""
		fi

		printf "$icon %s%%" `echo "$current" | bc`
	fi
	
	if [ $status = 1 ] && [ $current -ne $capacity ]; then
		if [ $1 -eq 4 ]; then
		    icon=""
		elif [ $1 -eq 3 ]; then
		    icon=""
		elif [ $1 -eq 2 ]; then
		    icon=""
		elif [ $1 -eq 1 ]; then
		    icon=""
		else
		    icon=""
		fi
		printf "$icon %s%%" `echo "$current" | bc`
	fi

}

layout() {
	lay_result="`xset -q | grep -i "led mask" | grep -o "....1..."`"
	lay="`[ -z $lay_result ] && echo "latam" || echo "es"`"
	echo -e " $lay"
}

lock() {
	cap_result=`xset q | grep -q 'Caps Lock: *on'`
	cap="`[ $? == 0 ] && echo "" || echo ""`"
	num_result=`xset q | grep -q 'Num Lock: *on'`
	num="`[ $? == 0 ] && echo "" || echo ""`"
	echo -e "$cap a $num 1" 
}

SLEEP_SEC=0.5
I=0
BAT_ITER=4
while :; do
	if [ $I -gt $BAT_ITER ]; then
		I=0
	fi
	echo "`cpu`  `mem`  `hdd`  `vol`  `bri`  `bat $I`  `layout`  `lock`  `dte`"
	I=`expr $I + 1`
	sleep $SLEEP_SEC
done

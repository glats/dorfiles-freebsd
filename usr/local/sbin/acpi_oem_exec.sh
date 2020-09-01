#!/bin/sh
if [ "$1" = "" -o "$2" = "" ]
then
    echo "usage: $0 notify oem_name"
    exit 1
fi
NOTIFY=`echo $1`
LOGGER="logger"
OEM=$2
DISPLAY_PIPE=/tmp/acpi_${OEM}_display
VOL_LEVEL=/tmp/vol_${OEM}
if [ ! -f $VOL_LEVEL ]
then
    VOL="`mixer -s vol | awk -F' ' '{split($2,a,":"); print (a[1]+a[2])/2}'`"
    echo $VOL > $VOL_LEVEL
fi
MIC_LEVEL=/tmp/mic_${OEM}
if [ ! -f $MIC_LEVEL ]
then
    VOL="`mixer -s mic | awk -F' ' '{split($2,a,":"); print (a[1]+a[2])/2}'`"
    echo $VOL > $MIC_LEVEL
fi
case ${NOTIFY} in
    0x01)
        MUTE=`sysctl -n dev.acpi_${OEM}.0.mute`
        if [ "$MUTE" = "1" ]
        then
            cat $VOL_LEVEL | xargs mixer vol
            sysctl dev.acpi_${OEM}.0.mute=0
            MESSAGE="vol unmute"
        else
            mixer vol 0
            sysctl dev.acpi_${OEM}.0.mute=1
            MESSAGE="vol mute"
        fi
        ;;
    0x02)
        mixer vol -5
        MESSAGE="vol down"
        ;;
    0x03)
        mixer vol +5
        MESSAGE="vol up"
        ;;
    0x04)
        LED=`sysctl -n dev.acpi_${OEM}.0.mic_led`
        if [ "$LED" = "1" ]
        then
            cat $MIC_LEVEL | xargs mixer mic
            sysctl dev.acpi_${OEM}.0.mic_led=0
            MESSAGE="mic unmute"
        else
            mixer mic 0
            sysctl dev.acpi_${OEM}.0.mic_led=1
            MESSAGE="mic mute"
        fi
        ;;
    0x05)
        BRI=`sysctl -n hw.acpi.video.lcd0.brightness`
        R=`echo $BRI-5 | bc`
        sysctl hw.acpi.video.lcd0.brightness=$R
        MESSAGE="brightness up"
	;;
    0x06)
        BRI=`sysctl -n hw.acpi.video.lcd0.brightness`
        R=`echo $BRI+5 | bc`
        sysctl hw.acpi.video.lcd0.brightness=$R
        MESSAGE="brightness down"
        ;;
    0x08)
        WLAN=`sysctl -n dev.acpi_${OEM}.0.wlan`
        if [ "$WLAN" = "1" ]
        then
            sysctl dev.acpi_${OEM}.0.wlan=0
            MESSAGE="wlan down"
        else
            sysctl dev.acpi_${OEM}.0.wlan=1
            MESSAGE="wlan up"
        fi
        ;;
esac
${LOGGER} ${MESSAGE}
if [ -p ${DISPLAY_PIPE} ]
then
    ${ECHO} ${MESSAGE} >> ${DISPLAY_PIPE} &
fi
exit 0

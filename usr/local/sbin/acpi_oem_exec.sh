#!/bin/sh
if [ "$1" = "" -o "$2" = "" ]
then
    echo "usage: $0 notify oem_name"
    exit 1
fi
NOTIFY=`echo $1`
LOGGER="logger"
CALC="bc"
BC_PRECOMMANDS="scale=2"
ECHO="echo"
CUT="cut"
MAX_LCD_BRIGHTNESS=100
MAX_VOLUME=100
OEM=$2
DISPLAY_PIPE=/tmp/acpi_${OEM}_display
case ${NOTIFY} in
    0x01)
        LEVEL=`sysctl -n dev.acpi_${OEM}.0.bluetooth`
        if [ "$LEVEL" = "1" ]
        then
            sysctl dev.acpi_${OEM}.0.bluetooth=0
            MESSAGE="bluetooth disabled"
        else
            sysctl dev.acpi_${OEM}.0.bluetooth=1
            MESSAGE="bluetooth enabled"
        fi
        ;;
    0x02)
        LEVEL=`sysctl -n dev.acpi_${OEM}.0.bluetooth`
        if [ "$LEVEL" = "1" ]
        then
            sysctl dev.acpi_${OEM}.0.bluetooth=0
            MESSAGE="bluetooth disabled"
        else
            sysctl dev.acpi_${OEM}.0.bluetooth=1
            MESSAGE="bluetooth enabled"
        fi
        ;;
esac
${LOGGER} ${MESSAGE}
if [ -p ${DISPLAY_PIPE} ]
then
    ${ECHO} ${MESSAGE} >> ${DISPLAY_PIPE} &
fi
exit 0

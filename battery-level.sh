#!/bin/bash                                                          

# Battery level warning script only work with a two-batteries laptop 
# Does only work for user whose personal directory is in /home/, and only works if there is only one user which personal directory is in /home/

battery1_level=`acpi -b | grep -oP '[0-9]+(?=%)' | cut -d $'\n' -f1`
battery2_level=`acpi -b | grep -oP '[0-9]+(?=%)' | cut -d $'\n' -f2`
battery1_capacity=`acpi -V | grep -oP '[0-9]+(?= mAh,)' | cut -d $'\n' -f1`
battery2_capacity=`acpi -V | grep -oP '[0-9]+(?= mAh,)' | cut -d $'\n' -f2`

total_battery_level=$((($battery1_level * $battery1_capacity + $battery2_level * $battery2_capacity)/($battery1_capacity + $battery2_capacity)))

is_ac_plugged_in=`acpi -a | grep "on-line" | wc -l`


user_to_send_notifications_to=`cat /etc/passwd | grep /home/ | cut -d: -f1`






low_level=10
very_low_level=6
critical_level=3



if [[ $is_ac_plugged_in -eq 0 ]]; then
    if [[ $total_battery_level -le $low_level && $total_battery_level -gt $very_low_level ]]; then
        sudo -u $user_to_send_notifications_to notify-send "Low battery warning"  "
        Battery level is ${total_battery_level}% (Which is low)" --urgency=normal --expire-time=10000
        
    elif [[ $total_battery_level -le $very_low_level && $total_battery_level -gt $critical_level ]]; then
        sudo -u saponace notify-send "Critical battery level warning"  "
        Battery level is ${total_battery_level}%
        You should really consider plugging an AC power source
        or shutting your system down now" --urgency=critical --expire-time=10000

    elif [[ $total_battery_level -le $critical_level ]]; then
        sudo -u $user_to_send_notifications_to notify-send "Suspending system now" "
        The system is currently hybrid-suspending
        Go plug an AC power source now
        (I know, it's hard to get off the couch)
        "
        pm-suspend-hybrid
    fi
fi





echo -e $total_battery_level'%\n('$battery1_level'% of '$battery1_capacity'mAh and '$battery2_level'% of '$battery2_capacity'mAh)'

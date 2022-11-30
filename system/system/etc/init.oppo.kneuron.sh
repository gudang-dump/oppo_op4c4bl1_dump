#!/system/bin/sh
#
#ifdef VENDOR_EDIT
#zhoumingjun@swdp.shanghai, 2018/07/19, add init.oppo.kneuron.sh
function log2kernel()
{
    echo "kneuron: "$1 > /dev/kmsg
}

loop_times=15

#wait data partition
if [ "$0" != "/data/kneuron/init.oppo.kneuron.sh" ]; then
    iter=0
    while [ iter -lt $loop_times ]; do
        #TODO: ext4 and f2fs
        if [ "`stat -f -c '%t' /data/`" == "ef53" -o "`stat -f -c '%t' /data/`" == "f2f52010" ]; then
            break
        fi
        log2kernel "wait for data partition, retry: iter=$iter"
        iter=$(($iter+1));
        sleep 2
    done

    if [ iter -ge $loop_times ]; then
        log2kernel "data partition is not mounted, Installation maybe fail"
    fi

    if [ -f /data/kneuron/init.oppo.kneuron.sh ]; then
        /system/bin/sh /data/kneuron/init.oppo.kneuron.sh
        log2kernel "run /data/kneuron/init.oppo.kneuron.sh"
        exit 0
    fi
else
        log2kernel "load sh from data partition"
fi

enable=`getprop persist.sys.enable.kneuron`

elsaenable=`getprop persist.sys.elsa.kernel_enable`
if [ "$elsaenable" == "1" ]; then
        elsaenable=1
else
        elsaenable=0
fi

case "$enable" in
    "1")
        log2kernel "module insmod beging!"
        n=0
        while [ n -lt 3 ]; do
            #load data folder module if it is exist
            if [ -f /data/kneuron/kneuron.ko ]; then
                insmod /data/kneuron/kneuron.ko elsa_enable=$elsaenable
            elif [ -f /vendor/lib/modules/kneuron.ko ]; then
                insmod /vendor/lib/modules/kneuron.ko elsa_enable=$elsaenable
            else
                insmod /system/lib/modules/kneuron.ko elsa_enable=$elsaenable
            fi
            if [ $? != 0 ];then
                n=$(($n+1));
                log2kernel "Error: insmod kneuron.ko failed, retry: n=$n"
            else
                log2kernel "module insmod succeed!"
                break
            fi
        done

        if [ n -ge 3 ]; then
             log2kernel "Fail to insmod kneuron module!!"
        fi

        restorecon -F /sys/devices/virtual/misc/kneuron/netlink_id
        restorecon -RF /sys/module/kneuron/parameters
        chown system:system /dev/kneuron
        chown root:system /sys/module/kneuron/parameters/cpuload_thresh
        chown root:system /sys/module/kneuron/parameters/io_thresh
        chown root:system /sys/module/kneuron/parameters/mem_thresh
        chown root:system /sys/module/kneuron/parameters/temperature_thresh
        chown root:system /sys/module/kneuron/parameters/trigger_time
        chown root:system /sys/module/kneuron/parameters/kneuron_work_enable
        chown root:system /sys/module/kneuron/parameters/elsa_enable_netlink
        chown root:system /sys/module/kneuron/parameters/elsa_socket_align_ms
        chown root:system /sys/module/kneuron/parameters/elsa_align_ms
        chown root:system /sys/devices/virtual/misc/kneuron/netlink_id
        chown system:system /data/kneuron
        log2kernel "module insmod end!"
        ;;
    "0")
        rmmod kneuron
        log2kernel "Remove kneuron module"
        ;;
esac
#endif /* VENDOR_EDIT */


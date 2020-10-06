#!/bin/bash

INTERVAL=$2
IFACE=$1
pkts_in=0
pkts_out=0
bytes_in=0
bytes_out=0

header="Time   Iface   IPkt/s   OPkt/s   TPkts/s   IMBytes/s   OMBytes/s   TMBytes/s"
header_intvl=10
header_count=0
intvl_count=0

if [[ "x$IFACE" == "x" || "x$INTERVAL" == "x" ]]; then
    echo "$0: a quick nicstat hack"
    echo "    Usage: $0 interface interval"
    exit
fi

while true; do
    if ! (($header_count % $header_intvl)); then
        printf "%8s %8s %8s %8s %8s %8s %8s %8s\n" "Time" "Iface" "IPkt/s" "Opkt/s" "Tpkt/s" "IMByte/s" "OMByte/s" "TMByte/s"
    fi

    if [ $intvl_count -eq 0 ]; then
        interval=`awk '{printf "%d", $1}' /proc/uptime`
    else
        interval=$INTERVAL
    fi
    intvl_count=$(($intvl_count + 1))

    date=`date +%H:%M:%S`
    iface_stats=`grep ${IFACE}:  /proc/net/dev| awk -F' ' '{print $2,$3,$10,$11}'`
    cur_bytes_in=`echo $iface_stats| awk -F' ' '{print $1}'`
    cur_pkts_in=`echo $iface_stats| awk -F' ' '{print $2}'`
    cur_bytes_out=`echo $iface_stats| awk -F' ' '{print $3}'`
    cur_pkts_out=`echo $iface_stats| awk -F' ' '{print $4}'`

    pkt_delta_in=$(($cur_pkts_in - $pkts_in))
    pkt_delta_out=$(($cur_pkts_out - $pkts_out))
    pkt_delta_total=$(($pkt_delta_in + $pkt_delta_out))

    bytes_delta_in=$(($cur_bytes_in - $bytes_in))
    bytes_delta_out=$(($cur_bytes_out - $bytes_out))
    bytes_delta_total=$(($bytes_delta_in + $bytes_delta_out))

    bytes_in=$cur_bytes_in
    bytes_out=$cur_bytes_out
    pkts_in=$cur_pkts_in
    pkts_out=$cur_pkts_out

    pkt_intvl_in=$(($pkt_delta_in / $interval))
    pkt_intvl_out=$(($pkt_delta_out / $interval))
    pkt_intvl_total=$(($pkt_delta_total / $interval))

    bytes_intvl_in=$(($bytes_delta_in / $interval))
    bytes_intvl_out=$(($bytes_delta_out / $interval))
    bytes_intvl_total=$(($bytes_delta_total/ $interval))

    mbytes_intvl_in=`echo "$bytes_intvl_in / 1048576" | bc`
    mbytes_intvl_out=`echo "$bytes_intvl_out / 1048576" | bc`
    mbytes_intvl_total=`echo "$bytes_intvl_total / 1048576" | bc`

    printf "%8s %8s %8d %8d %8d %8.2f %8.2f %8.2f\n" $date $IFACE $pkt_intvl_in $pkt_intvl_out $pkt_intvl_total $mbytes_intvl_in $mbytes_intvl_out $mbytes_intvl_total

    sleep $INTERVAL
    header_count=$(( $header_count + 1 ))
done

#!/bin/bash 
clearup(){
    echo ""
    echo " unloading kprove module ..."
    rmmod son_probe.ko 
    exit
}
trap "clearup" 2
sleep 500
#cat /sys/kernel/debug/tracing/trace_pipe

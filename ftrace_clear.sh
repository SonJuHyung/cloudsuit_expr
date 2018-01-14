#!/bin/bash  
DIR_FTRACE=/sys/kernel/debug/tracing

function clearing(){
    echo ""     
    echo " clearing ftrace ..."
    echo nop > ${DIR_FTRACE}/current_tracer 
    echo > ${DIR_FTRACE}/set_ftrace_filter 
    echo > ${DIR_FTRACE}/set_ftrace_pid
    echo > ${DIR_FTRACE}/trace 
    echo " done"
}

clearing

#!/bin/bash 
#PID=$(pgrep $1)

watch -n -0.1 "./_pid_check.sh -p $1"

##while [ -d /proc/${PID} ]
##do
##    ./_pid_check.sh -n $1
##done



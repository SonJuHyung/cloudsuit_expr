#!/bin/bash 

# common 
OP_TYPE=""
HP_TYPE=""
MFRG_TYPE=""
DIR_CUR=$(pwd) 
DIR_OPT=${DIR_CUR}/ftrace
DIR_FTRACE=/sys/kernel/debug/tracing

#PID=$(pgrep redis-server)

function usage()
{
    echo ""
    echo " usage : # ./ftrace_set.sh -p data_analytics -h thp -f ftrace_v1" 
    echo "       : # ./ftrace_set.sh -p graph_analytics -h thp -f ftrace_v2"
    echo "" 
    exit
}

function clearing(){
    echo ""     
    echo " clearing ftrace ..."
    echo nop > ${DIR_FTRACE}/current_tracer 
    echo > ${DIR_FTRACE}/set_ftrace_filter 
    echo > ${DIR_FTRACE}/set_ftrace_pid
    echo > ${DIR_FTRACE}/trace 
    echo " done"
}

trap 'clearing' 2


while getopts p:h:f: opt 
do
    case $opt in
        p) 
            if [ $OPTARG == "data_analytics" ] || [ $OPTARG == "data_caching" ] || [ $OPTARG == "data_serving" ] || [ $OPTARG == "graph_analytics" ] || [ $OPTARG == "inmemory_analytics" ] || [ $OPTARG == "media_streaming" ] || [ $OPTARG == "web_search" ] || [ $OPTARG == "web_serving"  ]
            then
                OP_TYPE=$OPTARG
            else
                echo "  error : benchmark type missing"
                usage 
                exit 0
            fi
            ;;
        h)
            HP_TYPE=$OPTARG
            ;;        
        f)
            MFRG_TYPE=$OPTARG
            ;;
        *)
            usage 
            exit 0
            ;;
    esac
done 

if [ $# -eq 0 ]
then 
    usage 
    exit 
fi 

# clearing ftrace 
echo " clearing ftrace ..."
echo nop > ${DIR_FTRACE}/current_tracer 
echo > ${DIR_FTRACE}/set_ftrace_filter 
echo > ${DIR_FTRACE}/set_ftrace_pid
echo > ${DIR_FTRACE}/trace 
echo " done"
# setting ftrace 
#echo " redis's pid is ${PID}" 
echo " setting ftrace"
#echo ${PID} > ${DIR_FTRACE}/set_ftrace_pid
echo __alloc_pages_nodemask > ${DIR_FTRACE}/set_ftrace_filter 
echo function_graph > ${DIR_FTRACE}/current_tracer 
echo "done"
# redirecting 
#cat ${DIR_FTRACE}/trace_pipe 
echo " redirecting..."
cat ${DIR_FTRACE}/trace_pipe >> ${DIR_OPT}/${OP_TYPE}/${HP_TYPE}/ftrace_${OP_TYPE}_${HP_TYPE}_${MFRG_TYPE}.txt


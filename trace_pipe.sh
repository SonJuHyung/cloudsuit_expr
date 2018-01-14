#!/bin/bash 

# common 
OP_TYPE=""
HP_TYPE=""
MFRG_TYPE=""
DIR_CUR=$(pwd) 
DIR_PROBE=${DIR_CUR}/kprobe
TRACE_DIR=/sys/kernel/debug/tracing
TRACE_PIPE=${TRACE_DIR}/trace_pipe 

trap 'echo " unloading kprove module ..."; rmmod son_probe.ko' 2
function usage()
{
    echo ""
    echo " usage : # ./exp_cloudsuit.sh -p data_analuyutics -h thp -f nf_v1" 
    echo "       : # ./exp_cloudsuit.sh -p data_caching -h hp -f f"
    echo ""

}

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
rmmod son_probe.ko
echo ""
echo " clearing trace output ..."
echo > ${TRACE_DIR}/trace  
echo ""
echo " loading kprove module ..."
insmod son_probe.ko 
echo " redirecting trace output ..."
cat ${TRACE_PIPE} >> ${DIR_PROBE}/${OP_TYPE}/${HP_TYPE}/probe_${OP_TYPE}_${HP_TYPE}_${MFRG_TYPE}.txt
echo ""
echo " unloading kprove module ..."
rmmod son_probe.ko 
exit


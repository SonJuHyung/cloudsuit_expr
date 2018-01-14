#!/bin/bash 

# common 
OP_TYPE=""
HP_TYPE=""
MFRG_TYPE=""
DIR_CUR=$(pwd) 

function usage()
{
    echo ""
    echo " usage : # ./parse_ftrace.sh -p data_analytics -h thp -f ftrace_v1" 
    echo "       : # ./parse_ftrace.sh -p graph_analytics -h thp -f ftrace_v2"
    echo "" 
    exit
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

DIR_LOG=${DIR_CUR}/ftrace/${OP_TYPE}/${HP_TYPE}

LOG_INPUT=${DIR_LOG}/ftrace_${OP_TYPE}_${HP_TYPE}_${MFRG_TYPE}.txt
LOG_RESULT=${DIR_LOG}/ftrace_${OP_TYPE}_${HP_TYPE}_${MFRG_TYPE}_result.txt
LOG_RAW=${DIR_LOG}/ftrace_${OP_TYPE}_${HP_TYPE}_${MFRG_TYPE}_raw.txt

rm -rf ${LOG_RESULT} ${LOG_RAW}
#cat ${LOG_INPUT} | sed -e '1,4d' |  awk '{ n=split($0,arr,"us"); printf("%s\n",arr[1]);}' > a.txt 
cat ${LOG_INPUT} |  awk '{ n=split($0,arr,"us"); printf("%s\n",arr[1]);}' > a.txt
cat a.txt | awk '{ n=split($0,arr,")"); printf("%s\n",arr[2]);}' | sed "s/ + /   /g" > ${LOG_RAW}
cat ${LOG_RAW} | awk 'BEGIN {sum=0} {for(i=1; i<=NF; i++) sum+=$i } END {print sum}' >> ${LOG_RESULT}

rm -rf a.txt
#cat b.txt | awk '{ n=split($0,arr," "); for(i=1; i < n; i++) printf("%s\n",arr[1]);}' 
#echo ${ARRAY}




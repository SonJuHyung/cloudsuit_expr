#!/bin/bash 

OP_TYPE=""
HP_TYPE=""
VERSION=0

usage(){
    echo ""    
    echo "  usage : # ./parse_probe.sh -h thp -p data_analytics -v probe_v1" 
    echo "          # ./parse_probe.sh -h nhp -d data_analytics -v probe_2" 
    echo ''
} 

if [ $# -eq 0 ]
then 
    usage 
    exit
fi

while getopts h:p:v: opt
do
    case $opt in 
        h)
            if [ $OPTARG == "nhp" ] || [ $OPTARG == "thp" ]
            then
                HP_TYPE=$OPTARG
            else  
                echo "  error : page type must be thp or nhp" 
                usage 
                exit 0
            fi           
            ;;
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
        v)
            VERSION=$OPTARG
            ;;
    esac
done
DIR_CUR=$(pwd) 
PROBE_DIR=${DIR_CUR}/kprobe/${OP_TYPE}/${HP_TYPE}
PROBE_FILE=${PROBE_DIR}/probe_${OP_TYPE}_${HP_TYPE}_${VERSION}.txt 
PROBE_CONTEXT=${PROBE_FILE}  

PREV_ADDR=0
DIFFERENCE=0

while read line 
do     
    PID=$(echo ${line}      | awk '{ split($0,parse_1,","); split(parse_1[1],parse_2,"pid:"); printf("%s",parse_2[2]);}') 
    VM_START=$(echo ${line} | awk '{ split($0,parse_1,","); split(parse_1[2],parse_2,":"); printf("%s",parse_2[2]);}') 
    VM_END=$(echo ${line}   | awk '{ split($0,parse_1,","); split(parse_1[3],parse_2,":"); printf("%s",parse_2[2]);}') 
    ADDRESS=$(echo ${line}  | awk '{ split($0,parse_1,","); split(parse_1[4],parse_2,":"); printf("%s",parse_2[2]);}') 


    # calculate difference
    if [ "${PREV_ADDR}" != 0 ] 
    then 
       VM_DIFFERENCE=$(echo ${VM_START} ${VM_END} | awk '{ difference=strtonum($2)-strtonum($1); printf("0x%x",difference)};')
       ADDR_DIFFERENCE=$(echo ${PREV_ADDR} ${ADDRESS} | awk '{ difference=strtonum($2)-strtonum($1); if (difference<0){difference=difference*(-1);} printf("0x%x",difference); }') 

       ABOVE_HPAGE=$(echo ${ADDR_DIFFERENCE} ${HPAGE_SIZE} ${ABOVE_HPAGE} | awk '{ diff=strtonum($1); hpage_size=strtonum($2); count=strtonum($3); if (diff >= hpage_size) { count+=1;} printf("%d",count); }') 
       IN_HPAGE=$(echo ${ADDR_DIFFERENCE} ${PAGE_SIZE} ${HPAGE_SIZE} ${IN_PAGE} | awk '{ diff=strtonum($1); page_size=strtonum($2); hpage_size=strtonum($3); count=strtonum($4);if (diff >= page_size && diff < hpage_size){ count+=1;} printf("%d",count); }')  
       IN_PAGE=$(echo ${ADDR_DIFFERENCE} ${PAGE_SIZE} ${IN_PAGE} | awk '{ diff=strtonum($1); page_size=strtonum($2); count=strtonum($3);if (diff < page_size){ count+=1;} printf("%d",count); }') 
       COUNT=`expr $COUNT + 1`
    fi
       
    # print out
    if [ "${DEBUG}" != 0 ]
    then
#        echo pid: ${PID}, vm_start: ${VM_START}, vm_end: ${VM_END}, addr: ${ADDRESS}, vma_size: ${VM_DIFFERENCE}, addr_diff: ${ADDR_DIFFERENCE}
        echo prev_addr: ${PREV_ADDR}, addr: ${ADDRESS}, addr_diff: ${ADDR_DIFFERENCE}, out_hpage: ${ABOVE_HPAGE}, in_hpage: ${IN_HPAGE}, in_page: ${IN_PAGE}, ${COUNT}

    else 
        echo ${PID}, ${VM_START}, ${VM_END}, ${ADDRESS} ${VM_DIFFERENCE}, ${ADDR_DIFFERENCE}, ${ABOVE_HPAGE}, ${IN_HPAGE}, ${IN_PAGE}, ${COUNT}
    fi

    PREV_ADDR=${ADDRESS} 
done < $PROBE_CONTEXT




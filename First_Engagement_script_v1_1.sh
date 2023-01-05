#!/bin/bash
unset TMOUT
clear

#Setting the colours VARS:
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
clear='\033[0m'

printf "${GREEN}####################################################################${clear}\n"
printf "${BLUE}########Hello $(whoami)#################################################${clear}\n"
printf "${BLUE}########Welcome to First Engagement Check Point script##############${clear}\n"
printf "${GREEN}####################################################################${clear}\n\n"
#Creating the needed vars:
OutboundDir=/var/log/FE_Files
HCP=$OutboundDir/hcp_results
CRASH_OUTPUTS=$OutboundDir/crash_info.log

function progress {

	LR='\033[1;31m'
    LG='\033[1;32m'
    LY='\033[1;33m'
    LC='\033[1;36m'
    LW='\033[1;37m'
    NC='\033[0m'
    if [ "${1}" = "0" ]; then TME=$(date +"%s"); fi
    SEC=`printf "%04d\n" $(($(date +"%s")-${TME}))`; SEC="$SEC sec"
    PRC=`printf "%.0f" ${1}`
    SHW=`printf "%3d\n" ${PRC}`
    LNE=`printf "%.0f" $((${PRC}/2))`
    LRR=`printf "%.0f" $((${PRC}/2-12))`; if [ ${LRR} -le 0 ]; then LRR=0; fi;
    LYY=`printf "%.0f" $((${PRC}/2-24))`; if [ ${LYY} -le 0 ]; then LYY=0; fi;
    LCC=`printf "%.0f" $((${PRC}/2-36))`; if [ ${LCC} -le 0 ]; then LCC=0; fi;
    LGG=`printf "%.0f" $((${PRC}/2-48))`; if [ ${LGG} -le 0 ]; then LGG=0; fi;
    LRR_=""
    LYY_=""
    LCC_=""
    LGG_=""
    for ((i=1;i<=13;i++))
    do
    	DOTS=""; for ((ii=${i};ii<13;ii++)); do DOTS="${DOTS}."; done
    	if [ ${i} -le ${LNE} ]; then LRR_="${LRR_}#"; else LRR_="${LRR_}."; fi
    	echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${DOTS}${LY}............${LC}............${LG}............ ${SHW}%${NC}\r"
    	if [ ${LNE} -ge 1 ]; then sleep .05; fi
    done
    for ((i=14;i<=25;i++))
    do
    	DOTS=""; for ((ii=${i};ii<25;ii++)); do DOTS="${DOTS}."; done
    	if [ ${i} -le ${LNE} ]; then LYY_="${LYY_}#"; else LYY_="${LYY_}."; fi
    	echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${LY}${LYY_}${DOTS}${LC}............${LG}............ ${SHW}%${NC}\r"
    	if [ ${LNE} -ge 14 ]; then sleep .05; fi
    done
    for ((i=26;i<=37;i++))
    do
    	DOTS=""; for ((ii=${i};ii<37;ii++)); do DOTS="${DOTS}."; done
    	if [ ${i} -le ${LNE} ]; then LCC_="${LCC_}#"; else LCC_="${LCC_}."; fi
    	echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${LY}${LYY_}${LC}${LCC_}${DOTS}${LG}............ ${SHW}%${NC}\r"
    	if [ ${LNE} -ge 26 ]; then sleep .05; fi
    done
    for ((i=38;i<=49;i++))
    do
    	DOTS=""; for ((ii=${i};ii<49;ii++)); do DOTS="${DOTS}."; done
    	if [ ${i} -le ${LNE} ]; then LGG_="${LGG_}#"; else LGG_="${LGG_}."; fi
    	echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${LY}${LYY_}${LC}${LCC_}${LG}${LGG_}${DOTS} ${SHW}%${NC}\r"
    	if [ ${LNE} -ge 38 ]; then sleep .05; fi
    done
}


function collect_CPinfo {
    nohup cpinfo -d -D -z -o $OutboundDir/$(hostname)_$(date +"%d-%m-%Y").cpinfo > /dev/null 2>&1
}

function collect_HCP {    
    nohup hcp -r all > /dev/null 2>&1
	if [ ! -d "$OutboundDir/hcp_results" ]; then
		mkdir $OutboundDir/hcp_results
	fi
    mv /var/log/hcp/last/* $HCP    
}
function collect_HCP_Performance {
    hcp --enable-product "Performance"
    hcp --enable-product "Threat Prevention"
    nohup hcp -r all > /dev/null 2>&1
	if [ ! -d "$OutboundDir/hcp_results" ]; then
		mkdir $OutboundDir/hcp_results
	fi
    mv /var/log/hcp/last/* $HCP
    hcp --disable-product "Performance"
    hcp --disable-product "Threat Prevention"
}

function collect_Spike_Detective {
    tar -czvf $OutboundDir/$(hostname)_$(date +"%d-%m-%Y")_spike_detective_logs.tgz /var/log/spike_detective/* > /dev/null 2>&1
    }

function additional_performance_files {
    fw tab -t connections -z -u > $OutboundDir/conntable_reason_$(date +"%d-%m-%Y").log
    fw tab -t connections -u > $OutboundDir/conntable_$(date +"%d-%m-%Y").log
    fwaccel stats -s > $OutboundDir/accel_stats_$(date +"%d-%m-%Y").log
    fw ctl affinity -l -a -r > $OutboundDir/affinity_$(date +"%d-%m-%Y").log
    fw ctl multik print_heavy_conn > $OutboundDir/havy_conns_$(date +"%d-%m-%Y").log
    fw ctl multik utilize > $OutboundDir/instance_util_$(date +"%d-%m-%Y").log
	fw ctl multik dynamic_dispatching get_mode > $OutboundDir/dispatcher-stat_$(date +"%d-%m-%Y").log	
	fw_mux all > $OutboundDir/fw_mux_$(date +"%d-%m-%Y").log	
    }

function crash_files {
    #echo "--------------------------------"
    #printf "${RED}Checking for Crash files${clear}\n"
    
    OUTPUT=$(ls -lsA /var/log/crash/ | wc -l)
    if [[ $OUTPUT -ge 2 ]]; then
        echo "/var/log/crash/:" >> $CRASH_OUTPUTS
        ls -lsA /var/log/crash/ >> $CRASH_OUTPUTS
        OUTPUT=$(ls -lsA /var/crash/ | wc -l)
    fi
    if [[ $OUTPUT -ge 2 ]]; then
        echo "/var/crash/:" >> $CRASH_OUTPUTS
        ls -lsA /var/crash/ >> $CRASH_OUTPUTS
        OUTPUT=$(ls -lsA /var/log/dump/usermode/ | wc -l)
    fi
    if [[ $OUTPUT -ge 2 ]]; then
        echo "/var/log/dump/usermode/:" >> $CRASH_OUTPUTS
        ls -lsA /var/log/dump/usermode/ >> $CRASH_OUTPUTS
        tar -czvf $CRASH_OUTPUTS/$(hostname)_$(date +"%d-%m-%Y")_crash_files /var/log/dump/usermode/*  > /dev/null 2>&1
    fi
    if [[ $CRASH_OUTPUTS == 0 ]]; then
        printf "${RED}The system didn't find any crash files${clear}\n"
    fi
    }

#Cheking if the folder exist, if not, creating it:
if [ -d "$OutboundDir" ]; then
    if [ "$(ls -A $OutboundDir)" ]; then
    	  
        printf "The system founds old files already exist\n"
		PS3="Please enter your choice:"
        options=("Keep the files" "Remove the files" "Quit")
        select opt in "${options[@]}"
            do
                case $opt in
                    "Keep the files")
                        echo -e "you chose 1 - Keeping the files \n"
                        break
                        ;;
                    "Remove the files")
                        echo -e "you chose 2 - Deleting old files \n"
                        rm -r $OutboundDir/*
                        break
                        ;;                 
                    "Quit")
                        exit 0
                        ;;
                    *) echo "invalid option $REPLY, please choose a valid option";;
                esac
            done
    fi
else
    mkdir /var/log/FE_Files
fi

    
# ------------------------------------------------------------------------------------------------

#Getting the user input:
printf "Please choose what should be collected:\n"
PS3="Please enter your choice:"
options=("Full Package (HCP, CPInfo, CPViewDB)" "Performace-related issues (Including option #1) and additional performance logs" "Crash files (Including option #1)" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Full Package (HCP, CPInfo, CPViewDB)")
            printf "you chose 1 - Full Package (HCP, CPInfo, CPViewDB)\n \nThe system will collect the following files: ${GREEN}\n1) cpinfo -d -D -z -o \n2) hcp -r all${clear}\n\n"
            Package=1
            break
            ;;
        "Performace-related issues (Including option #1) and additional performance logs")
            echo -e "you chose 2 - Performace-related issues (Including option #1) and additional performance logs\n \nThe system will collect the following files: ${GREEN}\n1) cpinfo -d -D -z -o \n2) hcp -r all \n3) /var/log/spike_detective/* \n4) connections table \n5) SXL and CoreXL Statistics${clear}\n\n"
            Package=2
            break
            ;;
        "Crash files (Including option #1)")
            echo -e "you chose 3 - Crash files (Including option #1) \n \nThe system will collect the following files: ${GREEN}\n1) /var/log/dump/usermode \n2) /var/log/crash/(folder's content only) \n3) /var/crash/ (folder's content only)${clear}\n\n"
            Package=3
            break
            ;;
        "Quit")
            exit 0
            ;;
        *) echo "invalid option $REPLY, please choose a valid option\n";;
    esac
done
echo "Please choose Yes or No if you wish to proceed:"
proceed=("Yes" "No")
select opt in "${proceed[@]}"
do
	  case $opt in
	  	"Yes")
	  	echo -e "you chose 1 - The system will collect the files"
	  	Choose=1
	  	break
	  	;;
	    "No")
	  	echo "you chose 2 - The system will not collect the files"
	  	Choose=2
	  	break
	  	;;
	  esac
done
if [[ $Package == "1" ]] && [[ $Choose == "1" ]]; then
    clear
	progress 0
	printf "${RED}Collecting CPinfo . . .${clear}\n"
	collect_CPinfo
	printf "${BLUE}CPinfo was collected${clear} \n"
	progress 10
	progress 20
	progress 30
	progress 40
	progress 50
	printf "${RED}Collecting HCP. . .${clear}\n"
    collect_HCP
	progress 60
	progress 70
	progress 80
	progress 90
	printf "${BLUE}HCP was collected${clear} \n"
	progress 100
    echo -e "\nYour outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"
    
elif [[ $Package == "2" ]] && [[ $Choose == "1" ]]; then
    clear
	progress 0
	printf "${RED}Collecting CPinfo . . .${clear}\n"
	collect_CPinfo
	printf "${BLUE}CPinfo was collected${clear} \n"
	progress 10
	progress 20
	printf "${RED}Collecting HCP. . .${clear}\n"
    collect_HCP_Performance
	printf "${BLUE}HCP was collected${clear} \n"
	progress 30
	progress 40
	printf "${RED}Collecting Spike_Detective logs . . .${clear}\n"
    collect_Spike_Detective
	progress 50
	additional_performance_files
	printf "${RED}Collecting Connections table . . .${clear}\n"
	progress 60
	printf "${RED}Collecting SXL Statistics . . .${clear}\n"
	progress 70
	printf "${RED}Collecting affinity information . . .${clear}\n"
	progress 80
	printf "${RED}Collecting CoreXL statistics. . .${clear}\n"
	progress 90
	printf "${RED}Collecting mux information statistics. . .${clear}\n"
	progress 100
    echo -e "\nYour outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"

elif [[ $Package == "3" ]] && [[ $Choose == "1" ]]; then
	clear
	progress 0
	printf "${RED}Collecting CPinfo . . .${clear}\n"
	collect_CPinfo
	printf "${BLUE}CPinfo was collected${clear} \n"
	progress 10
	progress 20
	progress 30
	progress 40
	progress 50
	printf "${RED}Collecting HCP. . .${clear}\n"
    collect_HCP
	progress 60
	progress 70
	printf "${BLUE}HCP was collected${clear} \n"
	progress 80
	printf "${RED}Checking for Crash files${clear}\n"
    crash_files
	progress 90
	progress 100
    echo -e "\nYour outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"
else
   echo 'Thank you for using the First Engagement Check Point script'
fi
